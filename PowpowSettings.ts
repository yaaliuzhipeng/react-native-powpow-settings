import { NativeModules,NativeEventEmitter, Platform } from 'react-native';
const { PowpowSettings:RNPowpowSettings } = NativeModules;
const RNPowpowSettingsListener = new NativeEventEmitter(RNPowpowSettings);

// Native Funcs
//
// setOrientation(orientation)
// getOrientation(callback) (e.value)
// setMediaVolume(volume,callback) [double(0 - 1), onError(e.value) ]
// getMediaVolume(callback) (e.value)
// setAppScreenBrightness(brightness) (double(0 -1))
// getAppScreenBrightness(callback) (e.value)
// setImmersiveStatusBar(immersive) (boolean) [Android Only]
// setRealFullscreen(fullscreen) (boolean)

const OrientationEvent = "onOrientationChanged";
type Orientation = "Auto" | "Portrait" | "PortraitUpsideDown" | "LandscapeLeft" | "LandscapeRight";
function mapOrientation(orientation: Orientation){
    if(orientation == "Auto") return 0;
    if(orientation == "Portrait") return 1;
    if(orientation == "PortraitUpsideDown") return 2;
    if(orientation == "LandscapeLeft") return 3;
    if(orientation == "LandscapeRight") return 4;
}

const setOrientation = (orientation:Orientation) => {
    RNPowpowSettings.setOrientation(mapOrientation(orientation));
}
const addOrientationListener = (callback:(event) => void) => {
    return RNPowpowSettingsListener.addListener(OrientationEvent,callback)
}
const setMediaVolume = (volume:number,onError?: (e:string) => void) => {
    RNPowpowSettings.setMediaVolume(volume,onError)
}
const getMediaVolume = async () => {
    return new Promise((resolve,reject) => {
        RNPowpowSettings.getMediaVolume((e) => {
            resolve(e.value)
        })
    })
}
const setAppScreenBrightness = (brightness:number) => {
    RNPowpowSettings.setAppScreenBrightness(brightness);
}
const getAppScreenBrightness = () => {
    return new Promise((resolve,reject) => {
        RNPowpowSettings.getAppScreenBrightness((e) => {
            resolve(e.value)
        })
    })
}
const setImmersiveStatusBar = (immersive:boolean) => {
    if(Platform.OS == 'android'){
        RNPowpowSettings.setImmersiveStatusBar(immersive);
    }
}
const setRealFullscreen = (fullscreen:boolean) => {
    RNPowpowSettings.setRealFullscreen(fullscreen);
}

export {
    setOrientation,
    addOrientationListener,
    setMediaVolume,
    getMediaVolume,
    setAppScreenBrightness,
    getAppScreenBrightness,
    setImmersiveStatusBar,
    setRealFullscreen
}
export default ({
    setOrientation,
    addOrientationListener,
    setMediaVolume,
    getMediaVolume,
    setAppScreenBrightness,
    getAppScreenBrightness,
    setImmersiveStatusBar,
    setRealFullscreen
})