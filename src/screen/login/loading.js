import {
  createCreationTimeIndex,
  createMD5Index,
  createMediaTable,
} from "../../database";
import { useContext, useEffect } from "react";

import { Context as AuthContext } from "../../context/AuthContext";

const Loading = () => {
  const { getLocalToken } = useContext(AuthContext);

  useEffect(() => {
    getLocalToken();
    runAsyncUseEffect();
  }, []);

  const runAsyncUseEffect = async () => {
    await createMediaTable();
    await createMD5Index();
    await createCreationTimeIndex();
  };

  return null;
};

export default Loading;
