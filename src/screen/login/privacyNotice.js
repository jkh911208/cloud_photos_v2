import { Button, Switch, Text } from "react-native-elements";
import { Linking, StyleSheet, View } from "react-native";
import React, { useEffect, useState } from "react";

import { SafeAreaView } from "react-navigation";
import updateEnitreLibrary from "../../compoent/updateEntireLibrary";

const PrivacyNotice = ({ navigation }) => {
  const [firstSwitch, setFirstSwitch] = useState(false);
  const toggleFirstSwitch = () =>
    setFirstSwitch((previousState) => !previousState);
  const [secondSwitch, setSecondSwitch] = useState(false);
  const toggleSecondSwitch = () =>
    setSecondSwitch((previousState) => !previousState);
  const [error, setError] = useState(null);

  const agreeAndContinue = () => {
    if (firstSwitch && secondSwitch) {
      navigation.navigate("loginFlow");
    } else {
      setError("Cannot continue without agreement");
    }
  };

  useEffect(() => {
    updateEnitreLibrary();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <Text h2>Privacy Notice</Text>
      <Text style={styles.bodyText}>
        {`- Cloud Photos will collect user photos and upload to our server.
- Photos will not be automatically removed until further user request.
- Cloud Photos will never sell user uploaded Photos to other companies`}
      </Text>
      <View style={styles.switch_view}>
        <Switch
          trackColor={{ false: "#767577", true: "#81b0ff" }}
          thumbColor={firstSwitch ? "#f5dd4b" : "#f4f3f4"}
          ios_backgroundColor="#3e3e3e"
          onValueChange={toggleFirstSwitch}
          value={firstSwitch}
          style={{ marginRight: 15 }}
        />
        <Text>{`I agree to backup my photos to Cloud Photos`}</Text>
      </View>
      <View style={styles.switch_view}>
        <Switch
          trackColor={{ false: "#767577", true: "#81b0ff" }}
          thumbColor={secondSwitch ? "#f5dd4b" : "#f4f3f4"}
          ios_backgroundColor="#3e3e3e"
          onValueChange={toggleSecondSwitch}
          value={secondSwitch}
          style={{ marginRight: 15 }}
        />
        <Text>{`I understand and agree that my photos will 
be uploaded and stored in Cloud Photos server`}</Text>
      </View>
      <Button
        title="Privacy Policy"
        onPress={() => Linking.openURL("https://www.cloudphotos.net/#/privacy")}
        buttonStyle={{
          width: 250,
          height: 50,
          borderRadius: 15,
          backgroundColor: "#939597",
          marginBottom: 15,
          marginTop: 20,
        }}
      />
      <Button
        title="Accept & continue"
        onPress={agreeAndContinue}
        buttonStyle={{
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
  switch_view: {
    flexDirection: "row",
    margin: 10,
  },
  container: {
    flex: 1,
    backgroundColor: "#F5dF4D",
    alignItems: "center",
    justifyContent: "center",
  },
  bodyText: {
    marginHorizontal: 45,
    marginVertical: 20,
    alignItems: "center",
    justifyContent: "center",
  },
  error: {
    color: "red",
    margin: 10,
    fontSize: 15,
  },
});

export default PrivacyNotice;
