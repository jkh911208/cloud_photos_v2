import { API_URL } from "@env";
import axios from "axios";

export default axios.create({
  baseURL: API_URL,
});
