import * as MediaLibrary from "expo-media-library";
import * as SecureStore from "expo-secure-store";

import JWT from "expo-jwt";
import { SECRET } from "@env";
import api from "../api/api";
import createDataContext from "./createDataContext";
import { navigate } from "../navigationRef";
import { truncateMediaTable } from "../database";

const authReducer = (state, action) => {
  switch (action.type) {
    case "clearerror":
      console.log("clear error");
      return { ...state, error: "" };
    case "error":
      console.log("Setting error reducer");
      return { ...state, error: action.payload };
    case "signout":
      console.log("sign out reducer");
      return { error: "", token: null };
    case "token":
      console.log("setting token reducer");
      return { error: "", token: action.payload };
    default:
      return state;
  }
};

const getLocalToken = (dispatch) => async () => {
  const token = await SecureStore.getItemAsync("token");
  if (token) {
    dispatch({ type: "token", payload: token });
    navigate("Gallery");
  } else {
    const permission = await MediaLibrary.getPermissionsAsync();
    console.log("get local token media permission", permission);
    if (permission.granted) {
      navigate("privacyNotice");
    } else {
      navigate("libraryAccess");
    }
  }
};

const signup =
  (dispatch) =>
  async ({ username, password, confirmPassword }) => {
    // make api request to sign up
    dispatch({
      type: "clearerror",
      payload: "",
    });

    // username cannot be longer than 30 characters
    if (username.length > 30) {
      return dispatch({
        type: "error",
        payload: "Username must be less than 30 characters",
      });
    }
    // username need to be at least 7 characters
    if (username.length < 7) {
      return dispatch({
        type: "error",
        payload: "Username must at least 7 characters",
      });
    }
    // username cannot have whitespace
    if (username.indexOf(" ") >= 0) {
      return dispatch({
        type: "error",
        payload: "Username should not contain white space",
      });
    }
    // username need to start with english alphabet
    if (!/[a-zA-Z]/.test(username.charAt(0))) {
      return dispatch({
        type: "error",
        payload: "Username must start with alphabet",
      });
    }

    // password cannot be longer than 30 characters
    if (password.length > 30) {
      return dispatch({
        type: "error",
        payload: "Password must be less than 30 characters",
      });
    }
    // password need to be at least 7 characters
    if (password.length < 7) {
      return dispatch({
        type: "error",
        payload: "Password must at least 7 characters",
      });
    }
    // passwrd need to match
    if (password != confirmPassword) {
      return dispatch({
        type: "error",
        payload: "Confirm Password doesn't match",
      });
    }
    // password must contain at least 1 lowercase alphabetical character
    if (password.search(/[a-z]/) < 0) {
      return dispatch({
        type: "error",
        payload:
          "Password must contain at least 1 owercase alphabetical character",
      });
    }
    // password must contain at least 1 upper alphabetical character
    if (password.search(/[A-Z]/) < 0) {
      return dispatch({
        type: "error",
        payload:
          "Password must contain at least 1 upper alphabetical character",
      });
    }
    // password must contain at least 1 number
    if (password.search(/[0-9]/) < 0) {
      return dispatch({
        type: "error",
        payload:
          "Password must contain at least 1 number",
      });
    }
    // password must contain at least 1 special character
    if (password.search(/[!@#$%^&*]/) < 0) {
      return dispatch({
        type: "error",
        payload:
          "Password must contain at least 1 special character (!,@,#,$,%,^,&,*)",
      });
    }

    // all test passed, make request to server
    try {
      const response = await api.post(
        "/api/v1/user/signup",
        {
          username,
          password,
        },
        {
          headers: {
            "X-Custom-Auth": JWT.encode({ timestamp: Date.now() }, SECRET),
          },
        }
      );
      console.log(response.data);
      await SecureStore.setItemAsync("token", response.data.access_token);
      console.log("set secure store");
      dispatch({ type: "token", payload: response.data.access_token });
      console.log("dispatch type token finished");
      // navigate to main flow

      navigate("configScreen");
    } catch (err) {
      console.log("sign up failed");
      dispatch({ type: "error", payload: "Sign up failed, Please try later" });
    }
  };

const signin =
  (dispatch) =>
  async ({ username, password }) => {
    // make api request to sign in
    try {
      var bodyFormData = new FormData();
      // console.log(username, password);
      bodyFormData.append("username", username);
      bodyFormData.append("password", password);
      console.log("signin, make request");

      const headers = {
        "Content-Type": "multipart/form-data",
        "X-Custom-Auth": JWT.encode({ timestamp: Date.now() }, SECRET),
      };
      // console.log(headers)
      const response = await api.post(
        "/api/v1/user/login",
        (data = bodyFormData),
        {
          headers,
        }
      );
      // console.log(response.data);
      await SecureStore.setItemAsync("token", response.data.access_token);
      // console.log(response.data.access_token);
      console.log("set secure store");
      dispatch({ type: "token", payload: response.data.access_token });
      console.log("dispatch type token finished");
      // navigate to main flow
      navigate("configScreen");
    } catch (err) {
      console.log("sign in failed");
      dispatch({ type: "error", payload: "Sign in failed" });
    }
  };

const signout = (dispatch) => {
  return async () => {
    await SecureStore.deleteItemAsync("token");
    await truncateMediaTable();
    dispatch({ type: "signout" });
    navigate("loading");
  };
};

export const { Provider, Context } = createDataContext(
  authReducer,
  { signup, signin, signout, getLocalToken },
  { token: null, error: "" }
);
