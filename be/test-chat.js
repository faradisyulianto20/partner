const { io } = require('socket.io-client');

const socket = io('http://localhost:3000/partner/chat', {
    transports: ['websocket'],
});

socket.on('connect', () => {
    console.log('connected', socket.id);

    socket.emit('join', {
        matchId: 'dcda570f-556b-4ea3-a937-4ab668846376',
        userId: 'u1',
        roomType: 'PSYCHOLOGIST',
        role: 'USER',
    });

    socket.emit('message', {
        matchId: 'dcda570f-556b-4ea3-a937-4ab668846376',
        userId: 'u1',
        content: 'Halo dok',
        roomType: 'PSYCHOLOGIST',
        role: 'USER',
    });
});

socket.on('joined', (data) => console.log('joined', data));
socket.on('message', (msg) => console.log('message', msg));
socket.on('connect_error', (err) => console.error('connect_error', err.message));
socket.on('error', (err) => console.error('error', err));
