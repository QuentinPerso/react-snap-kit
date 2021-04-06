declare module 'react-native-snapchat-kit' {
  interface SnapchatUserData {
    displayName: string;
    externalId: string;
    avatar: string | null;
    accessToken: string;
    error?: any;
  }

  export default class SnapchatKit {
    static login(): Promise<SnapchatUserData | null>;
    static getUserInfo(): Promise<SnapchatUserData | null>;
    static isLogged(): Promise<boolean>;
    static logout(): Promise<boolean>;
    static sharePhotoAtUrl(photoUrl: string, stickerUrl?: string, stickerPosX?: DoubleRange, stickerPosY?: DoubleRange, attachmentUrl?: string, caption?: string): Promise<boolean>;
    static shareVideoAtUrl(videoUrl: string, stickerUrl: string, stickerPosX: DoubleRange, stickerPosY: DoubleRange, attachmentUrl: string, caption: string): Promise<boolean>;
    static lensSnapContent(lensUUID: string, caption: string, attachmentUrl: string, launchData: string): Promise<boolean>;
  }
}
