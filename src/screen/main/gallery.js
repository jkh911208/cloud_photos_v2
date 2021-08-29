import * as SecureStore from "expo-secure-store";

import { AppState, Dimensions, FlatList, View } from "react-native";
import { Header, Icon, Image, Text } from "react-native-elements";
import React, { useEffect, useState } from "react";
import { deleteUsingMD5Async, getMedia } from "../../database";

import JWT from "expo-jwt";
import { SECRET } from "@env";
import { SafeAreaView } from "react-navigation";
import { Spinner } from "native-base";
import getCloudData from "../../compoent/getCloudData";
import updateLocalPhotoLibrary from "../../compoent/updateLocalPhotoLibrary";
import uploadPhotoToCloud from "../../compoent/uploadPhotoToCloud";

const Gallery = ({ navigation }) => {
  const thumbnailWidth = Dimensions.get("window").width / 4;
  const [refreshing, setRefreshing] = useState(false);
  const [image, setNewImage] = useState([]);
  const [token, setToken] = useState(null);
  var appState = AppState.currentState;
  var trackImage = image;

  const setImage = (data) => {
    setNewImage(data);
    trackImage = data;
  };

  useEffect(() => {
    SecureStore.getItemAsync("token").then((result) => {
      setToken(result);
    });
    runInitSetup();
  }, []);

  const runInitSetup = async () => {
    var result = await getMedia(Date.now());
    if (result.length == 0) {
      await updateLocalPhotoLibrary(0);
    } else {
      setImage(result);
      const localUpdated = await updateLocalPhotoLibrary(
        result[result.length - 1].creationTime
      );
      if (localUpdated) {
        result = await getMedia(Date.now());
        setImage(result);
      }
    }
    await getCloudData();
    result = await getMedia(Date.now());
    setImage(result);
    if (await uploadPhotoToCloud()) {
      result = await getMedia(Date.now(), image.length);
      setImage(result);
    }
  };

  useEffect(() => {
    AppState.addEventListener("change", _handleAppStateChange);

    return () => {
      AppState.removeEventListener("change", _handleAppStateChange);
    };
  }, []);

  const _handleAppStateChange = (nextAppState) => {
    console.log("app state changed", appState, nextAppState);
    if (appState === "background" && nextAppState === "active") {
      console.log("changed from background to active");
      changeListener();
    }
    appState = nextAppState;
  };

  const changeListener = async () => {
    if (AppState.currentState == "active") {
      console.log("app state changed to active");
      console.log("track image type", typeof trackImage);
      const updated = await updateLocalPhotoLibrary(
        trackImage[trackImage.length - 1].creationTime
      );
      console.log("local library updated", updated);
      if (updated) {
        var result = await getMedia(
          Date.now(),
          image.length > 0 ? image.length : 100
        );
        setImage(result);
      }
      await getCloudData();
      result = await getMedia(
        Date.now(),
        image.length > 0 ? image.length : 100
      );
      setImage(result);
      if (await uploadPhotoToCloud()) {
        result = await getMedia(Date.now(), image.length);
        setImage(result);
      }
    } else {
      console.log("app state", AppState.currentState);
    }
  };

  const renderItem = ({ item, index }) => {
    var cloudStatus;
    var iconColor;
    if (item.local_id == null) {
      // loaded from cloud, not on device
      cloudStatus = "download-cloud";
      iconColor = "green";
    } else if (item.local_id != null && item.cloud_id != null) {
      // on device and on cloud
      cloudStatus = "cloud";
      iconColor = "green";
    } else if (item.local_id != null && item.cloud_id == null) {
      if (Date.now() - 604800000 > item.creationTime) {
        // not backed up but older than 7 days
        cloudStatus = "cloud-off";
        iconColor = "red";
      } else {
        // not backed up waiting for backup
        cloudStatus = "upload-cloud";
        iconColor = "orange";
      }
    }

    var isVideo;
    if (item.duration > 0) {
      isVideo = true;
      var min = Math.floor(item.duration / 60);
      var sec = Math.floor(item.duration % 60);
      if (min < 10) {
        min = "0" + min.toString();
      }
      if (sec < 10) {
        sec = "0" + sec.toString();
      }
      cloudStatus = "cloud-off";
      iconColor = "red";
    }

    return (
      <View>
        <Image
          source={{
            uri: item.thumbnail_uri,
            cache: "force-cache",
            headers: {
              Authorization: `Bearer ${token}`,
              "X-Custom-Auth": JWT.encode({ timestamp: Date.now() }, SECRET),
            },
          }}
          style={{
            width: thumbnailWidth - 2,
            height: thumbnailWidth - 2,
            margin: 1,
          }}
          onPress={() => {
            console.log("index", index);
            navigation.navigate("SingleView", {
              image,
              token,
              initIndex: index,
              setThumbImage: setImage,
            });
          }}
          onError={async () => {
            if (token) {
              console.log("not able to load image in gallery view");
              await deleteUsingMD5Async(item.md5);
              setImage(await getMedia(Date.now(), image.length));
            }
          }}
        />
        {isVideo ? (
          <View
            style={{
              flexDirection: "row",
              position: "absolute",
              bottom: 8,
              left: 5,
              borderColor: "black",
              borderRadius: 15,
              borderWidth: 1,
              backgroundColor: "white",
              alignContent: "center",
              alignContent: "center",
            }}
          >
            <Icon name="play" size={14} type="feather" color="black" />
            <Text>
              {min}:{sec}
            </Text>
          </View>
        ) : null}
        <Icon
          name={cloudStatus}
          size={14}
          type="feather"
          color={iconColor}
          containerStyle={{
            position: "absolute",
            top: 5,
            right: 5,
            borderColor: "black",
            borderRadius: 15,
            borderWidth: 1,
            backgroundColor: "white",
          }}
        />
      </View>
    );
  };

  const reload = async () => {
    setRefreshing(true);
    console.log("reload");
    await changeListener();
    setRefreshing(false);
  };

  const onEndReached = async () => {
    console.log("end reached gallery");
    const result = await getMedia(
      image[image.length - 1].creationTime,
      image.length
    );
    if (result.length > 0) {
      setImage(image.concat(result));
    }
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: "#939597" }}>
      <Header
        statusBarProps={{ backgroundColor: "#939597" }}
        centerComponent={{
          text: "Cloud Photos",
          style: { color: "#fff", fontSize: 25 },
        }}
        containerStyle={{
          backgroundColor: "#939597",
        }}
      />
      {image.length > 0 ? (
        <FlatList
          horizontal={false}
          numColumns={4}
          data={image}
          renderItem={renderItem}
          keyExtractor={(item) => item.md5}
          onRefresh={reload}
          refreshing={refreshing}
          onEndReached={onEndReached}
        />
      ) : (
        <View style={{ flex: 1, alignItems: "center" }}>
          <Text style={{ color: "white", fontSize: 30 }}>
            Updating Database
          </Text>
          <Spinner />
        </View>
      )}
    </SafeAreaView>
  );
};

export default Gallery;
