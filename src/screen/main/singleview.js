import * as MediaLibrary from "expo-media-library";

import { Alert, Dimensions, FlatList, StyleSheet, View } from "react-native";
import { Button, Footer, FooterTab } from "native-base";
import { Icon, Image } from "react-native-elements";
import React, { useRef, useState } from "react";
import { deleteUsingMD5Async, getMedia } from "../../database";

import GestureRecognizer from "react-native-swipe-gestures";
import ImageZoom from "react-native-image-pan-zoom";
import JWT from "expo-jwt";
import { SECRET } from "@env";
import { SafeAreaView } from "react-navigation";
import { Video } from "expo-av";
import api from "../../api/api";

const imageDisplayWidth = Dimensions.get("window").width;

const SingleView = ({ navigation }) => {
  const { token, image, initIndex, setThumbImage } = navigation.state.params;
  const [renderImage, setRenderImage] = useState(image);
  const flatlistRef = useRef();
  var currentIndex = initIndex;

  const onSwipeDown = () => {
    navigation.goBack();
  };

  const onSwipeUp = () => {
    console.log("swipe up");
  };

  const deleteAlert = async () =>
    new Promise((resolve) => {
      Alert.alert(
        "Delete Image",
        "Do you want to delete image from Cloud?",
        [
          {
            text: "Cancel",
            onPress: async () => {
              resolve(false);
            },
            style: "cancel",
          },
          {
            text: "Delete",
            onPress: async () => {
              resolve(true);
            },
          },
        ],
        { cancelable: false }
      );
    });

  const CustomFooter = () => {
    return (
      <Footer>
        <FooterTab style={styles.footer}>
          <Button>
            <Icon name="share" color={"white"} type="feather" />
          </Button>
          <Button>
            <Icon name="info" color={"white"} type="feather" />
          </Button>
          <Button>
            <Icon
              name="trash"
              color={"white"}
              type="feather"
              onPress={async () => {
                console.log("delete current index of", currentIndex);
                console.log(renderImage[currentIndex]);
                const id = renderImage[currentIndex].local_id;
                const md5 = renderImage[currentIndex].md5;
                const cloudId = renderImage[currentIndex].cloud_id;
                var deleteResult = null;
                if (id != null) {
                  try {
                    deleteResult = await MediaLibrary.deleteAssetsAsync(id);
                  } catch {
                    deleteResult = false;
                  }
                } else {
                  deleteResult = await deleteAlert();
                }
                console.log("delete result", deleteResult);

                if (deleteResult) {
                  var temp = [];
                  console.log(typeof currentIndex, currentIndex);
                  for (let i = 0; i < renderImage.length; i++) {
                    if (i != currentIndex) {
                      temp.push(renderImage[i]);
                    } else {
                      console.log(`deleting ${i}`);
                    }
                  }
                  setRenderImage(temp);
                  flatlistRef.current.scrollToIndex({ index: currentIndex });
                  setThumbImage(temp);
                  deleteUsingMD5Async(md5);
                  if (cloudId) {
                    const config = {
                      headers: {
                        Authorization: `Bearer ${token}`,
                        "X-Custom-Auth": JWT.encode(
                          { timestamp: Date.now() },
                          SECRET
                        ),
                      },
                    };
                    // console.log(config);
                    // console.log(api);
                    api.delete(`/api/v1/photo/${cloudId}`, config);
                  }
                }
              }}
            />
          </Button>
          <Button>
            <Icon
              name="chevron-left"
              color={"white"}
              onPress={() => {
                navigation.goBack();
              }}
            />
          </Button>
        </FooterTab>
      </Footer>
    );
  };

  const renderItem = ({ item, index }) => {
    console.log(`render item index of ${index}`);
    if (item.duration > 0) {
      return renderVideo(item);
    } else {
      return renderPhoto(item);
    }
  };

  const renderVideo = (item) => {
    const imageHeight = (item.height * imageDisplayWidth) / item.width;
    return (
      <GestureRecognizer
        onSwipeDown={() => onSwipeDown()}
        onSwipeUp={() => onSwipeUp()}
      >
        <View style={styles.container}>
          <Video
            source={{
              uri: item.uri,
              cache: "force-cache",
              headers: {
                Authorization: `Bearer ${token}`,
                "X-Custom-Auth": JWT.encode({ timestamp: Date.now() }, SECRET),
              },
            }}
            style={{
              width: imageDisplayWidth,
              height: imageHeight,
            }}
            useNativeControls
            resizeMode="contain"
            resizeMethod="auto"
            onError={async () => {
              console.log("not able to load single view video");
              await deleteUsingMD5Async(item.md5);
              const media = await getMedia(Date.now(), renderImage.length);
              setRenderImage(media);
              setThumbImage(media);
            }}
          />
        </View>
      </GestureRecognizer>
    );
  };

  const renderPhoto = (item) => {
    const imageHeight = (item.height * imageDisplayWidth) / item.width;
    return (
      <GestureRecognizer
        onSwipeDown={() => onSwipeDown()}
        onSwipeUp={() => onSwipeUp()}
      >
        <View style={styles.container}>
          <ImageZoom
            cropWidth={Dimensions.get("window").width}
            cropHeight={Dimensions.get("window").height}
            imageWidth={imageDisplayWidth}
            imageHeight={imageHeight}
          >
            <Image
              source={{
                uri: item.uri,
                cache: "force-cache",
                headers: {
                  Authorization: `Bearer ${token}`,
                  "X-Custom-Auth": JWT.encode(
                    { timestamp: Date.now() },
                    SECRET
                  ),
                },
              }}
              style={{
                width: imageDisplayWidth,
                height: imageHeight,
              }}
              resizeMethod="auto"
              onError={async () => {
                console.log("not able to load single view photo");
                await deleteUsingMD5Async(item.md5);
                const media = await getMedia(Date.now(), renderImage.length);
                setRenderImage(media);
                setThumbImage(media);
              }}
            />
          </ImageZoom>
        </View>
      </GestureRecognizer>
    );
  };

  const onEndReached = async () => {
    console.log(
      "end reached single view",
      renderImage[renderImage.length - 1].creationTime
    );
    const result = await getMedia(
      renderImage[renderImage.length - 1].creationTime
    );
    console.log("result length", result.length);
    if (result.length > 0) {
      const temp = renderImage.concat(result);
      setRenderImage(temp);
      setThumbImage(temp);
    }
  };

  return (
    <>
      <SafeAreaView style={styles.container}>
        <FlatList
          ref={flatlistRef}
          getItemLayout={(renderItem, index) => {
            // console.log("get item layout called", index, renderItem.length);
            return {
              length: imageDisplayWidth,
              index,
              offset: imageDisplayWidth * index,
            };
          }}
          initialScrollIndex={initIndex}
          horizontal
          pagingEnabled
          data={renderImage}
          showsVerticalScrollIndicator={false}
          renderItem={renderItem}
          keyExtractor={(item) => item.md5}
          onEndReached={onEndReached}
          onMomentumScrollEnd={(ev) => {
            currentIndex = Math.floor(
              ev.nativeEvent.contentOffset.x / imageDisplayWidth
            );
          }}
        />
        <CustomFooter />
      </SafeAreaView>
    </>
  );
};

const styles = StyleSheet.create({
  footer: {
    backgroundColor: "black",
  },
  container: {
    flex: 1,
    alignContent: "space-between",
    justifyContent: "space-evenly",
    backgroundColor: "black",
  },
});
export default SingleView;
