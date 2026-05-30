const { io } = require('socket.io-client');

function readArg(name, fallback) {
    const prefix = `--${name}=`;
    const match = process.argv.find((item) => item.startsWith(prefix));
    return match ? match.slice(prefix.length) : fallback;
}

function toBool(value) {
    if (value === true || value === 'true') {
        return true;
    }
    if (value === false || value === 'false') {
        return false;
    }
    return Boolean(value);
}

const baseUrl = readArg('url', 'http://localhost:3000');
const mode = readArg('mode', 'human-chat');
const matchId = readArg('matchId', 'demo-match-id');
const userId = readArg('userId', 'demo-user-id');
const roomType = readArg('roomType', mode === 'psychologist-chat' || mode === 'psychologist-call' ? 'PSYCHOLOGIST' : 'HUMAN');
const role = readArg('role', 'USER');
const content = readArg('content', `ws probe message from ${mode}`);
const timeoutMs = Number(readArg('timeout', '15000'));
const sampleRate = Number(readArg('sampleRate', '16000'));
const autoStop = toBool(readArg('autoStop', 'true'));
const probe = readArg('probe', 'connect');
const connectOnly = probe === 'connect' || toBool(readArg('connectOnly', 'false'));
const hasRealRoomIds = matchId !== 'demo-match-id' && userId !== 'demo-user-id';

const namespaceMap = {
    'ai-voice': '/ai/voice',
    'human-chat': '/partner/chat',
    'human-call': '/partner/call',
    'psychologist-chat': '/partner/chat',
    'psychologist-call': '/partner/call',
};

const namespacePath = namespaceMap[mode];

if (!namespacePath) {
    console.error(`Unknown mode: ${mode}`);
    console.error('Available modes: ai-voice, human-chat, human-call, psychologist-chat, psychologist-call');
    process.exit(1);
}

const socket = io(`${baseUrl}${namespacePath}`, {
    transports: ['websocket'],
    autoConnect: false,
});

const timer = setTimeout(() => {
    console.error(`Timeout after ${timeoutMs}ms`);
    socket.disconnect();
    process.exit(2);
}, timeoutMs);

function finish(code) {
    clearTimeout(timer);
    socket.disconnect();
    process.exit(code);
}

function fail(message, code = 1) {
    console.error(message);
    finish(code);
}

socket.on('connect', () => {
    console.log(`[connect] ${socket.id}`);

    if (connectOnly) {
        setTimeout(() => finish(0), 250);
        return;
    }

    if ((mode === 'human-chat' || mode === 'human-call' || mode === 'psychologist-chat' || mode === 'psychologist-call') && !hasRealRoomIds) {
        fail(
            'This mode needs a real matchId and userId. Run with --probe=connect for namespace health check, or pass real room data for a full flow test.',
            3,
        );
        return;
    }

    if (mode === 'ai-voice') {
        socket.emit('start', {
            userId,
            sampleRate,
        });
        if (autoStop) {
            setTimeout(() => socket.emit('stop'), 750);
        }
        return;
    }

    socket.emit('join', {
        matchId,
        userId,
        roomType,
        role,
    });

    if (mode === 'human-chat' || mode === 'psychologist-chat') {
        socket.once('joined', () => {
            socket.emit('message', {
                matchId,
                userId,
                content,
                roomType,
                role,
            });
        });
        return;
    }

    const signalingPayload = {
        matchId,
        userId,
        roomType,
        role,
    };

    socket.once('joined', () => {
        socket.emit('offer', {
            ...signalingPayload,
            offer: { type: 'offer', sdp: 'ws-probe-offer' },
        });
    });

    setTimeout(() => {
        socket.emit('answer', {
            ...signalingPayload,
            answer: { type: 'answer', sdp: 'ws-probe-answer' },
        });
    }, 900);

    setTimeout(() => {
        socket.emit('ice', {
            ...signalingPayload,
            candidate: { candidate: 'ws-probe-candidate' },
        });
    }, 1300);
});

socket.on('session', (data) => console.log('[session]', data));
socket.on('joined', (data) => console.log('[joined]', data));
socket.on('message', (data) => console.log('[message]', data));
socket.on('offer', (data) => console.log('[offer]', data));
socket.on('answer', (data) => console.log('[answer]', data));
socket.on('ice', (data) => console.log('[ice]', data));
socket.on('transcript', (data) => console.log('[transcript]', data));
socket.on('assistant_text', (data) => console.log('[assistant_text]', data));
socket.on('assistant_audio', (data) => console.log('[assistant_audio]', data));
socket.on('exception', (data) => {
    console.error('[exception]', data);
    finish(1);
});
socket.on('error', (data) => {
    console.error('[error]', data);
    finish(1);
});
socket.on('connect_error', (error) => {
    console.error('[connect_error]', error.message);
    finish(1);
});
socket.on('disconnect', (reason) => console.log('[disconnect]', reason));
socket.onAny((eventName, ...args) => {
    if (!['session', 'joined', 'message', 'offer', 'answer', 'ice', 'transcript', 'assistant_text', 'assistant_audio', 'error', 'exception'].includes(eventName)) {
        console.log(`[event:${eventName}]`, ...args);
    }
});

socket.connect();

if (mode === 'ai-voice') {
    socket.on('assistant_audio', () => {
        finish(0);
    });

    socket.on('assistant_text', () => {
        if (!autoStop) {
            finish(0);
        }
    });

    socket.on('transcript', () => {
        if (!autoStop) {
            finish(0);
        }
    });
}

if (mode === 'human-chat' || mode === 'psychologist-chat') {
    socket.on('message', () => {
        finish(0);
    });

    socket.on('joined', () => {
        console.log('[probe] joined room, waiting for message echo');
    });
}

if (mode === 'human-call' || mode === 'psychologist-call') {
    let seenOffer = false;
    let seenAnswer = false;
    let seenIce = false;

    socket.on('offer', () => {
        seenOffer = true;
        if (seenAnswer && seenIce) {
            finish(0);
        }
    });

    socket.on('answer', () => {
        seenAnswer = true;
        if (seenOffer && seenIce) {
            finish(0);
        }
    });

    socket.on('ice', () => {
        seenIce = true;
        if (seenOffer && seenAnswer) {
            finish(0);
        }
    });

    socket.on('joined', () => {
        console.log('[probe] joined room, waiting for signaling echo');
    });
}