import * as FileSystem from "expo-file-system";
import * as MediaLibrary from "expo-media-library";

import { insertMediaAsync } from "../database";

const updateEnitreLibrary = async () => {
  console.log("update entire PhotoLibrary");

  var options = {
    first: 100,
    sortBy: [["creationTime", false]],
    createdBefore: Date.now(),
    mediaType: [MediaLibrary.MediaType.photo, MediaLibrary.MediaType.video],
  };

  while (true) {
    var asset = await MediaLibrary.getAssetsAsync(options);
    // console.log(asset.assets);
    for (let i = 0; i < asset.assets.length; i++) {
      let fsInfo = await FileSystem.getInfoAsync(asset.assets[i].uri, {
        md5: true,
      });
      // console.log(fsInfo);
      // console.log("updatel local photo library", asset.assets[i])
      await insertMediaAsync(
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
    if (!asset.hasNextPage) {
      break;
    }
    options.createdBefore = asset.assets[asset.assets.length - 1].creationTime;
  }
};

export default updateEnitreLibrary;
