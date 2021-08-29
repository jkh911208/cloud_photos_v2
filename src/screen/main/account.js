import * as SecureStore from "expo-secure-store";

import { FlatList, StyleSheet, View } from "react-native";
import { Header, ListItem, Switch, Text } from "react-native-elements";
import React, { useContext, useEffect, useState } from "react";

import { Context as AuthContext } from "../../context/AuthContext";
import Constants from "expo-constants";
import { SafeAreaView } from "react-navigation";

const Account = ({ navigation }) => {
  const { signout } = useContext(AuthContext);
  const [wifiOnly, setWifiOnly] = useState();

  useEffect(() => {
    SecureStore.getItemAsync("wifiOnly").then((result) => {
      const currentWifiOnly = result == "false" ? false : true;
      setWifiOnly(currentWifiOnly);
    });
  }, []);

  const toggleWifiOnly = () => {
    const newValue = !wifiOnly;
    console.log("new wifi only value", newValue);
    SecureStore.setItemAsync("wifiOnly", newValue.toString()).then((result) => {
      setWifiOnly(newValue);
    });
  };

  const account_list = [
    {
      title: "Backup Finished",
      onPress: () => {
        navigation.navigate("BackupFinished");
      },
    },
    {
      title: "Need Backup",
      onPress: () => {
        navigation.navigate("NeedBackup");
      },
    },
    {
      title: "Loaded From Cloud",
      onPress: () => {
        SecureStore.getItemAsync("token").then((result) => {
          navigation.navigate("LoadedFromCloud", { token: result });
        });
      },
    },
    {
      title: "Sign Out",
      onPress: signout,
    },
  ];

  const renderItem = ({ item }) => {
    return (
      <ListItem bottomDivider onPress={item.onPress}>
        <ListItem.Content>
          <ListItem.Title>{item.title}</ListItem.Title>
        </ListItem.Content>
      </ListItem>
    );
  };

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: "#939597" }}>
      <Header
        statusBarProps={{ backgroundColor: "#939597" }}
        centerComponent={{
          text: "Account",
          style: { color: "#fff", fontSize: 25 },
        }}
        containerStyle={{
          backgroundColor: "#939597",
        }}
      />
      <View style={styles.switch_view}>
        <View style={styles.single_switch_view}>
          <Switch
            trackColor={{ false: "#767577", true: "#81b0ff" }}
            thumbColor={wifiOnly ? "#f5dd4b" : "#f4f3f4"}
            ios_backgroundColor="#3e3e3e"
            onValueChange={toggleWifiOnly}
            value={wifiOnly}
            style={{ marginRight: 15 }}
          />
          <View style={styles.single_switch_text_view}>
            <Text>{`Upload Photos on Wifi Only`}</Text>
          </View>
        </View>
        <View style={styles.border_view}></View>
      </View>
      <FlatList
        data={account_list}
        renderItem={renderItem}
        keyExtractor={(item) => item.title}
      />
      <Text>{`v${Constants.manifest.version}`}</Text>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  switch_view: {
    backgroundColor: "white",
  },
  single_switch_view: {
    flexDirection: "row",
    marginTop: 10,
    marginLeft: 5,
    paddingBottom: 10,
  },
  border_view: {
    borderBottomColor: "#939597",
    borderBottomWidth: 0.5,
  },
  single_switch_text_view: {
    flex: 1,
    alignContent: "space-between",
    justifyContent: "space-evenly",
  },
});

export default Account;
