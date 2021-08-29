import * as MediaLibrary from "expo-media-library";

import { Button, Text } from "react-native-elements";
import React, { useState } from "react";

import { Icon } from "react-native-elements";
import { SafeAreaView } from "react-navigation";
import { StyleSheet } from "react-native";

const LibraryAccess = ({ navigation }) => {
  const [error, setError] = useState(null);
  const getAccess = async () => {
    console.log("Get access to media library");
    const permission = await MediaLibrary.requestPermissionsAsync();
    console.log(permission);
    if (!permission.granted) {
      setError(`Give Cloud Photos permission in setting`);
    } else {
      navigation.navigate("privacyNotice");
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <Icon name="image" size={120} type="feather" />
      <Text style={{ marginVertical: 30 }} h4>{`Cloud Photos need full access 
      to your media library`}</Text>
      <Text style={styles.bodyText}>
        The Cloud Photos app needs this access to let you view and backup photos
        from this device
      </Text>
      <Button
        title="Allow access to all photos"
        onPress={getAccess}
        buttonStyle={{
          marginVertical: 40,
          width: 250,
          height: 60,
          borderRadius: 15,
          backgroundColor: "#4189d6",
        }}
      />
      {error ? <Text style={styles.error}>{error}</Text> : null}
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5dF4D",
    alignItems: "center",
    justifyContent: "center",
  },
  bodyText: {
    marginHorizontal: 60,
    alignItems: "center",
    justifyContent: "center",
  },
  error: {
    color: "red",
    margin: 10,
    fontSize: 20,
  },
});

export default LibraryAccess;
