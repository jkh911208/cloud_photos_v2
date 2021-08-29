import * as SecureStore from "expo-secure-store";

import { API_URL, SECRET } from "@env";
import { checkMD5, insertMedia, updateCloudIDAsync } from "../database";

import JWT from "expo-jwt";
import { Platform } from "react-native";
import api from "../api/api";

const getCloudData = async () => {
  const token = await SecureStore.getItemAsync("token");
  if (!token) {
    return null;
  } else {
    console.log("get cloud data", Platform.OS);
  }

  const config = {
    headers: {
      Authorization: `Bearer ${token}`,
      "X-Custom-Auth": JWT.encode({ timestamp: Date.now() }, SECRET),
    },
  };

  var lastCloudCreated = 0;

  while (true) {
    console.log(lastCloudCreated);

    const result = await api.get(
      `/api/v1/photo/list/${lastCloudCreated}`,
      config
    );

    const data = result.data.result;
    const hasNext = result.data.has_next;

    // console.log(data);

    for (let i = 0; i < data.length; i++) {
      const md5Exist = await checkMD5(data[i].md5);
      if (md5Exist == 1) {
        await updateCloudIDAsync(data[i].md5, data[i].id);
      } else {
        await insertMedia(
          null,
          data[i].id,
          data[i].original_width,
          data[i].original_height,
          `${API_URL}/api/v1/photo/${data[i].resize}`,
          `${API_URL}/api/v1/photo/${data[i].thumbnail}`,
          data[i].original_datetime,
          data[i].md5,
          data[i].duration
        );
      }

      lastCloudCreated = Math.max(lastCloudCreated, data[i].created);
    }

    if (!hasNext) {
      break;
    }
  }
};

export default getCloudData;
