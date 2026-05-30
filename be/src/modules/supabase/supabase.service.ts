import { Injectable } from '@nestjs/common';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
    private supabase: SupabaseClient;

    constructor() {
        const supabaseUrl = process.env.SUPABASE_URL?.trim();
        const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY?.trim() ?? process.env.SUPABASE_KEY?.trim();

        if (!supabaseUrl || !supabaseKey) {
            throw new Error('Supabase configuration is missing');
        }

        if (!supabaseKey.startsWith('eyJ')) {
            throw new Error(
                'Supabase key is invalid. Use SUPABASE_SERVICE_ROLE_KEY (preferred) or a valid JWT-style Supabase anon/service key, not the publishable key.',
            );
        }

        this.supabase = createClient(supabaseUrl, supabaseKey);
    }

    async uploadFile(file: Express.Multer.File, bucket = 'cv', folder = ''): Promise<string> {
        const fileName = `${Date.now()}-${file.originalname}`;
        const path = folder ? `${folder}/${fileName}` : fileName;

        const { error } = await this.supabase.storage
            .from(bucket)
            .upload(path, file.buffer, {
                contentType: file.mimetype,
                upsert: false,
            });

        if (error) {
            throw new Error(`Upload failed: ${error.message}`);
        }

        const { data: publicUrlData } = this.supabase.storage
            .from(bucket)
            .getPublicUrl(path);

        return publicUrlData.publicUrl;
    }

    async uploadPrivateFile(file: Express.Multer.File, bucket = 'cv', folder = ''): Promise<string> {
        const fileName = `${Date.now()}-${file.originalname}`;
        const path = folder ? `${folder}/${fileName}` : fileName;

        const { error } = await this.supabase.storage
            .from(bucket)
            .upload(path, file.buffer, {
                contentType: file.mimetype,
                upsert: false,
            });

        if (error) {
            throw new Error(`Upload failed: ${error.message}`);
        }

        return path;
    }

    async getSignedUrl(bucket: string, path: string, expiresInSeconds = 60 * 60): Promise<string> {
        const { data, error } = await this.supabase.storage
            .from(bucket)
            .createSignedUrl(path, expiresInSeconds);

        if (error) {
            throw new Error(`Failed to create signed url: ${error.message}`);
        }

        return data.signedUrl;
    }

    async deleteFile(fileUrl: string, bucket = 'cv'): Promise<void> {
        const url = new URL(fileUrl);
        const path = decodeURIComponent(url.pathname.split(`/object/public/${bucket}/`)[1] ?? '');

        if (!path) {
            return;
        }

        const { error } = await this.supabase.storage
            .from(bucket)
            .remove([path]);

        if (error) {
            console.error('Failed to delete file from Supabase:', error.message);
        }
    }
}