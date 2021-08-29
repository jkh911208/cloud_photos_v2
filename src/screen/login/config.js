import * as SecureStore from "expo-secure-store";

import { Button, Switch, Text } from "react-native-elements";
import React, { useState } from "react";
import { StyleSheet, View } from "react-native";

import { SafeAreaView } from "react-navigation";
import {upsertConfigData} from "../../database"

const configScreen = ({ navigation }) => {
  const [wifiOnly, setWifiOnly] = useState(true);
  const toggleWifiOnly = () => setWifiOnly((previousState) => !previousState);

  const confirmSetting = async () => {
    await SecureStore.setItemAsync("wifiOnly", wifiOnly.toString());
    navigation.navigate("mainFlow");
  };

  return (
    <SafeAreaView style={styles.container}>
      <Text h2>Basic Config</Text>
      <View style={styles.switch_view}>
        <Switch
          trackColor={{ false: "#767577", true: "#81b0ff" }}
          thumbColor={wifiOnly ? "#f5dd4b" : "#f4f3f4"}
          ios_backgroundColor="#3e3e3e"
          onValueChange={toggleWifiOnly}
          value={wifiOnly}
          style={{ marginRight: 15 }}
        />
        <Text>{`Upload Photos on Wifi Only`}</Text>
      </View>
      <Button
        title="Confirm"
        onPress={confirmSetting}
        buttonStyle={{
          width: 250,
          height: 60,
          borderRadius: 15,
          backgroundColor: "#4189d6",
        }}
      />
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  switch_view: {
    flexDirection: "row",
    marginVertical: 50,
  },
  container: {
    flex: 1,
    backgroundColor: "#F5dF4D",
    alignItems: "center",
    justifyContent: "center",
  },
});

export default configScreen;
