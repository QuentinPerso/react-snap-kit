import { NativeModules, NativeEventEmitter } from 'react-native';

export const RNSnapchatKit = NativeModules.SnapchatKit;
export const RNSnapchatKitEmitter = new NativeEventEmitter(RNSnapchatKit);

export default class SnapchatKit {
  static login() {
    return new Promise((resolve, reject) => {
      RNSnapchatKit.login()
        .then((result) => {
          if(result.error) {
            reject(result.error);
          } else { 
            this.getUserInfo()
              .then(resolve)
              .catch(reject);
          }
        })
        .catch(e => reject(e)); 
    });
  }

  static async isLogged() {
    const { result } = await RNSnapchatKit.isUserLoggedIn();
    return result;
  }

  static async logout() {
    const { result } = await RNSnapchatKit.logout();
    return result;
  }

  static getUserInfo() {
    return new Promise((resolve, reject) => {
      RNSnapchatKit.fetchUserData()
        .then(async (tmp) => {
          const data = tmp;
          if (data === null) {
            resolve(null);
          } else {
            const res = await RNSnapchatKit.getAccessToken();
            data.accessToken = res.accessToken;
            resolve(data);
          }
        })
        .catch(e => { reject(e) });
    });
  }

  static async sharePhotoAtUrl(photoImageSourceOrUrl, stickerImageSourceOrUrl, stickerPosX, stickerPosY, attachmentUrl, caption) {
	const resolveAssetSource = require('react-native/Libraries/Image/resolveAssetSource');

	const resolvedPhoto = resolveAssetSource(photoImageSourceOrUrl);
	const resolvedSticker = resolveAssetSource(stickerImageSourceOrUrl);

	const { result } = await RNSnapchatKit.sharePhotoResolved(
		resolvedPhoto, resolvedPhoto == null ? photoImageSourceOrUrl : null, 
		resolvedSticker, resolvedSticker == null ? stickerImageSourceOrUrl : null, 
		stickerPosX, stickerPosY, 
		attachmentUrl, 
		caption).catch(e => { reject(e) });

    return result;
  }


  static async shareVideoAtUrl(videoUrl, stickerImageSourceOrUrl, stickerPosX, stickerPosY, attachmentUrl, caption) {
    const resolveAssetSource = require('react-native/Libraries/Image/resolveAssetSource');

	const resolvedSticker = resolveAssetSource(stickerImageSourceOrUrl);

	const { result } = await RNSnapchatKit.shareVideoAtUrl(
		videoUrl, 
		resolvedSticker, resolvedSticker == null ? stickerImageSourceOrUrl : null, 
		stickerPosX, stickerPosY, 
		attachmentUrl, 
		caption).catch(e => { reject(e) });

    return result;
  }
  static async lensSnapContent(lensUUID, caption, attachmentUrl, launchData) {
    
    return new Promise((resolve, reject) => {
      RNSnapchatKit.lensSnapContent(lensUUID, caption, attachmentUrl, launchData)
        .then((result) => {
          if(result.error) {
            reject(result.error);
          } else { 
            resolve(result)
          }
        })
        .catch(e => reject(e)); 
    });
  }

}
