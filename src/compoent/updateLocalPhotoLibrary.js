import * as FileSystem from "expo-file-system";
import * as MediaLibrary from "expo-media-library";

import { checkMD5, insertMedia } from "../database";

const updateLocalPhotoLibrary = async (finishTime = 0) => {
  console.log("updateLocalPhotoLibrary", finishTime);
  var updated = false;

  var options = {
    first: 50,
    sortBy: [["creationTime", false]],
    createdBefore: Date.now(),
    mediaType: [MediaLibrary.MediaType.photo, MediaLibrary.MediaType.video],
  };

  while (true) {
    var asset = await MediaLibrary.getAssetsAsync(options);
    // console.log(asset.assets);
    var exitLoop = false;
    for (let i = 0; i < asset.assets.length; i++) {
      let fsInfo = await FileSystem.getInfoAsync(asset.assets[i].uri, {
        md5: true,
      });
      // console.log("file information")
      // console.log(fsInfo);
      // console.log("updatel local photo library", asset.assets[i])

      if (asset.assets[i].creationTime < finishTime) {
        exitLoop = true;
        break;
      }

      // check md5
      const md5Exist = await checkMD5(fsInfo.md5);
      console.log("md5 exist", md5Exist);
      if (md5Exist == 1) {
        console.log("md5 exist");
      } else {
        updated = true;
        await insertMedia(
          asset.assets[i].id,
          null,
          asset.assets[i].width,
          asset.assets[i].height,
          asset.assets[i].uri,
          asset.assets[i].uri,
          asset.assets[i].creationTime,
          fsInfo.md5,
          asset.assets[i].duration
        );
      }
    }
    if (!asset.hasNextPage || exitLoop) {
      break;
    }
    options.createdBefore = asset.assets[asset.assets.length - 1].creationTime;
  }
  return updated;
};

export default updateLocalPhotoLibrary;
