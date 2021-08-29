import { Button, Icon, Input, Text } from "react-native-elements";
import React, { useContext, useState } from "react";
import { StyleSheet, View } from "react-native";

import { Context as AuthContext } from "../../context/AuthContext";
import { KeyboardAwareScrollView } from "react-native-keyboard-aware-scroll-view";

const SignUp = ({ navigation }) => {
  const { state, signup } = useContext(AuthContext);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [usernameFocus, setUsernameFocus] = useState(false);
  const [passwordFocus, setPasswordFocus] = useState(false);
  const [confirmPasswordFocus, setConfirmPasswordFocus] = useState(false);
  const [confirmPassword, setConfirmPassword] = useState("");

  return (
    <KeyboardAwareScrollView
      contentContainerStyle={styles.container}
      resetScrollToCoords={{ x: 0, y: 0 }}
      scrollEnabled={true}
    >
      {usernameFocus ? (
        <View>
          <View style={{ flexDirection: "row" }}>
            {username.length >= 7 ? (
              <Icon name="check" color={"green"} type="feather" />
            ) : (
              <Icon name="x" color={"red"} type="feather" />
            )}
            <Text style={styles.confirmText}>Username at least 7 character</Text>
          </View>
          <View style={{ flexDirection: "row" }}>
            {username.length < 30 ? (
              <Icon name="check" color={"green"} type="feather" />
            ) : (
              <Icon name="x" color={"red"} type="feather" />
            )}
            <Text style={styles.confirmText}>Username shorter than 30 character</Text>
          </View>
          <View style={{ flexDirection: "row" }}>
            {username.indexOf(" ") >= 0 ? (
              <Icon name="x" color={"red"} type="feather" />
            ) : (
              <Icon name="check" color={"green"} type="feather" />
            )}
            <Text style={styles.confirmText}>Username not have white space</Text>
          </View>
          <View style={{ flexDirection: "row" }}>
            {/[a-zA-Z]/.test(username.charAt(0)) ? (
              <Icon name="check" color={"green"} type="feather" />
            ) : (
              <Icon name="x" color={"red"} type="feather" />
            )}
            <Text style={styles.confirmText}>Username start with alphabet</Text>
          </View>
        </View>
      ) : null}
      <Input
        onFocus={() => {
          setUsernameFocus(true);
        }}
        onBlur={() => {
          setUsernameFocus(false);
        }}
        label="Username"
        value={username}
        onChangeText={setUsername}
        autoCapitalize="none"
        autoCorrect={false}
      />
      {passwordFocus ? (
        <View>
          <View style={{ flexDirection: "row" }}>
            {password.length >= 7 ? (
              <Icon name="check" color={"green"} type="feather" />
            ) : (
              <Icon name="x" color={"red"} type="feather" />
            )}
            <Text style={styles.confirmText}>Password longer than 7 character</Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            {password.length < 30 ? (
              <Icon name="check" color={"green"} type="feather" />
            ) : (
              <Icon name="x" color={"red"} type="feather" />
            )}
            <Text style={styles.confirmText}>Password shorter than 30 character</Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            {password.search(/[a-z]/) < 0 ? (
              <Icon name="x" color={"red"} type="feather" />
            ) : (
              <Icon name="check" color={"green"} type="feather" />
            )}
            <Text style={styles.confirmText}>password contain 1 lower case</Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            {password.search(/[A-Z]/) < 0 ? (
              <Icon name="x" color={"red"} type="feather" />
            ) : (
              <Icon name="check" color={"green"} type="feather" />
            )}
            <Text style={styles.confirmText}>password contain 1 upper case</Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            {password.search(/[0-9]/) < 0 ? (
              <Icon name="x" color={"red"} type="feather" />
            ) : (
              <Icon name="check" color={"green"} type="feather" />
            )}
            <Text style={styles.confirmText}>password contain 1 number</Text>
          </View>

          <View style={{ flexDirection: "row" }}>
            {password.search(/[!@#$%^&*]/) < 0 ? (
              <Icon name="x" color={"red"} type="feather" />
            ) : (
              <Icon name="check" color={"green"} type="feather" />
            )}
            <Text style={styles.confirmText}>password contain 1 special character (!@#$%^&*)</Text>
          </View>
        </View>
      ) : null}
      <Input
        onFocus={() => {
          setPasswordFocus(true);
        }}
        onBlur={() => {
          setPasswordFocus(false);
        }}
        label="Password"
        value={password}
        onChangeText={setPassword}
        autoCapitalize="none"
        autoCorrect={false}
        secureTextEntry
      />
      {confirmPasswordFocus ? (
        <View>
          <View style={{ flexDirection: "row" }}>
            {password == confirmPassword ? (
              <Icon name="check" color={"green"} type="feather" />
            ) : (
              <Icon name="x" color={"red"} type="feather" />
            )}
            <Text style={styles.confirmText}>Password match</Text>
          </View>
        </View>
      ) : null}
      <Input
        onFocus={() => {
          setConfirmPasswordFocus(true);
        }}
        onBlur={() => {
          setConfirmPasswordFocus(false);
        }}
        label="Confirm Password"
        value={confirmPassword}
        onChangeText={setConfirmPassword}
        autoCapitalize="none"
        autoCorrect={false}
        secureTextEntry
      />
      {state.error ? <Text style={styles.error}>{state.error}</Text> : null}
      <Button
        title="Sign Up"
        onPress={() => signup({ username, password, confirmPassword })}
        buttonStyle={{
          width: 200,
          height: 40,
          borderRadius: 25,
          backgroundColor: "#939597",
        }}
      />
      <Text
        style={styles.signInText}
        onPress={() => navigation.navigate("Signin")}
      >
        Already have account? Sign in
      </Text>
    </KeyboardAwareScrollView>
  );
};

const styles = StyleSheet.create({
  confirmText: {
    marginLeft: 5,
  },
  error: {
    marginBottom: 25,
  },
  container: {
    flex: 1,
    backgroundColor: "#F5dF4D",
    alignItems: "center",
    justifyContent: "center",
  },
  signInText: {
    marginTop: 25,
    color: "#939597",
  },
});

export default SignUp;
