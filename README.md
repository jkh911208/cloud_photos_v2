# Before run this project in your local dev machine, you should clone https://github.com/jkh911208/api_cloud_photos and follow the instruction to run REST API service in your dev machine.
------------
## Please note, this is expo managed react-native project, you will need expo app in your physical iOS/Android device or have simulator in your dev machine to run this project.
------------
## I use node version 12 for dev, if you have different version of node, please consider reinstall your node to version 12. If you are using macOS, you can use NVM to easily install different version of node.
------------
## Get ready to run the code
1. Make sure compatible/suggested node and npm is installed
2. install expo-cli globally by "npm install -g expo-cli"
3. run "npm install" to install all the dependencies
4. rename ".env.example" to ".env"
5. fill up .env to meet your environment. API_URL=http://<ip_of_your_machine_running_api>:5000
6. SECRET is to verify app with API, but if you are running API in non-production mode, then it will skip the verification. if you are running api in production mode then you will need to set SECRET to match APP_SECRET in API
6. run "start" script in package.json, it will show you QR code, you can scan QR code in your mobile device to run app in your device. or you can start simulator.