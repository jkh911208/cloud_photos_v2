import { createAppContainer, createSwitchNavigator } from "react-navigation";

import Account from "./src/screen/main/account";
import { Provider as AuthProvider } from "./src/context/AuthContext";
import BackupFinished from "./src/screen/account/backupFinished";
import Gallery from "./src/screen/main/gallery";
import { Icon } from "react-native-elements";
import LibraryAccess from "./src/screen/login/libraryAccess";
import LoadedFromCloud from "./src/screen/account/loadedFromCloud";
import Loading from "./src/screen/login/loading";
import NeedBackup from "./src/screen/account/needBackup";
import PrivacyNotice from "./src/screen/login/privacyNotice";
import React from "react";
import SignIn from "./src/screen/login/signIn";
import SignUp from "./src/screen/login/signUp";
import SingleView from "./src/screen/main/singleview";
import configScreen from "./src/screen/login/config";
import { createBottomTabNavigator } from "react-navigation-tabs";
import { createStackNavigator } from "react-navigation-stack";
import { setNavigator } from "./src/navigationRef";

const loginFlowStackNavigator = createStackNavigator({
  Signup: {
    screen: SignUp,
    navigationOptions: {
      headerShown: false,
    },
  },
  Signin: {
    screen: SignIn,
    navigationOptions: {
      headerShown: false,
    },
  },
});

const mediaStackNavigator = createStackNavigator(
  {
    Gallery: {
      screen: Gallery,
      navigationOptions: {
        headerShown: false,
      },
    },
    SingleView: {
      screen: SingleView,
      navigationOptions: {
        headerShown: false,
      },
    },
  },
  {
    navigationOptions: ({ navigation }) => {
      let tabBarVisible;
      if (navigation.state.routes.length > 1) {
        navigation.state.routes.map((route) => {
          if (route.routeName === "SingleView") {
            tabBarVisible = false;
          } else {
            tabBarVisible = true;
          }
        });
      }
      return {
        tabBarVisible,
      };
    },
  }
);

const accountStackNavigator = createStackNavigator({
  Account: {
    screen: Account,
    navigationOptions: {
      headerShown: false,
    },
  },
  BackupFinished: {
    screen: BackupFinished,
    navigationOptions: {
      headerShown: false,
    },
  },
  LoadedFromCloud: {
    screen: LoadedFromCloud,
    navigationOptions: {
      headerShown: false,
    },
  },
  NeedBackup: {
    screen: NeedBackup,
    navigationOptions: {
      headerShown: false,
    },
  },
});

const mainFlowBottomTabNavigator = createBottomTabNavigator(
  {
    Media: {
      screen: mediaStackNavigator,
      navigationOptions: {
        tabBarIcon: () => {
          return <Icon name="image" />;
        },
      },
    },
    Account: {
      screen: accountStackNavigator,
      navigationOptions: {
        tabBarIcon: () => {
          return <Icon name="settings" />;
        },
      },
    },
  },
  {
    tabBarOptions: {
      style: {
        backgroundColor: "white",
        height: 50,
      },
    },
  }
);

const switchNavigator = createSwitchNavigator({
  loading: Loading,
  libraryAccess: LibraryAccess,
  privacyNotice: PrivacyNotice,
  loginFlow: loginFlowStackNavigator,
  configScreen: configScreen,
  mainFlow: mainFlowBottomTabNavigator,
});

const App = createAppContainer(switchNavigator);

export default () => {
  return (
    <AuthProvider>
      <App
        ref={(navigator) => {
          setNavigator(navigator);
        }}
      />
    </AuthProvider>
  );
};
