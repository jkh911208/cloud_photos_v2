import { Button, Input, Text } from "react-native-elements";
import React, { useContext, useState } from "react";

import { Context as AuthContext } from "../../context/AuthContext";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";
import { StyleSheet } from "react-native";

const SignIn = ({ navigation }) => {
  const { state, signin } = useContext(AuthContext);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  return (
    <KeyboardAwareScrollView
      contentContainerStyle={styles.container}
      resetScrollToCoords={{ x: 0, y: 0 }}
      scrollEnabled={true}
    >
      <Input
        label="Username"
        value={username}
        onChangeText={setUsername}
        autoCapitalize="none"
        autoCorrect={false}
      />
      <Input
        label="Password"
        value={password}
        onChangeText={setPassword}
        autoCapitalize="none"
        autoCorrect={false}
        secureTextEntry
      />
      {state.error ? <Text>{state.error}</Text> : null}
      <Button
        title="Sign In"
        onPress={() => signin({ username, password })}
        buttonStyle={{
          width: 200,
          height: 40,
          borderRadius: 25,
          backgroundColor: "#939597",
        }}
      />
      <Text
        style={styles.signUpText}
        onPress={() => navigation.navigate("Signup")}
      >
        Don't have account? Sign Up
      </Text>
    </KeyboardAwareScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F5dF4D",
    alignItems: "center",
    justifyContent: "center",
  },
  signUpText: {
    marginTop: 25,
    color: "#939597",
    alignItems: "center",
    justifyContent: "center",
  },
});

export default SignIn;
