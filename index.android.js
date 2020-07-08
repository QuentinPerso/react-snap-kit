import { NativeModules, NativeEventEmitter } from 'react-native';
import { resolve } from 'uri-js';

export const RNSnapchatKit = NativeModules.SnapchatLogin;
export const RNSnapchatKitEmitter = new NativeEventEmitter(RNSnapchatKit);

export default class SnapchatLogin {
  static addListener(eventType, listener, context) {
    return RNSnapchatKitEmitter.addListener(eventType, listener, context);
  }

  static login() {
    return new Promise((resolve, reject) => {
      const succeededListener = this.addListener('LoginSucceeded', (res) => {
        succeededListener.remove();
        failedListener.remove();
        this.getUserInfo().then(resolve).catch(reject); 
      });
      const failedListener = this.addListener('LoginFailed', (res) => {
        succeededListener.remove();
        failedListener.remove();
        resolve(false);
      });
      RNSnapchatKit.login();
    });
  }

  static async isLogged() {
    const result = await RNSnapchatKit.isUserLoggedIn();
    const resultJSON = JSON.parse(result);
    return !!resultJSON.result;
  }

  static async logout() {
    const result = await RNSnapchatKit.logout();
    const resultJSON = JSON.parse(result);
    return !!resultJSON.result;
  }

  static getUserInfo() {
    return new Promise((resolve, reject) => {
      RNSnapchatKit.fetchUserData()
        .then((tmp) => {
          const data = JSON.parse(tmp);
          if (data === null) {
            resolve(null);
          } else {
            resolve(data);
          }
        })
        .catch(e => reject(e));
    });
  }
}
