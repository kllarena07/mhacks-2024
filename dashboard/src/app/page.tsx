'use client'
import WebRTCComponent from "./components/webrtc/client";
import { ChakraProvider, Portal, useDisclosure, Text } from "@chakra-ui/react";

import React, { useState } from "react";

import theme from "./themeAdmin";

import MainPanel from "./MainPanel";
import PanelContainer from "./PanelContainer";
import PanelContent from "./PanelContent";
import Dash from "./Dashboard";

const Home = () => {
  const mainPanel = React.createRef();
  return (
    <ChakraProvider theme={theme} resetCSS={false}>
      <MainPanel
        ref={mainPanel}
        w="100%"
        h="100vh"
        minH="100vh">
        <PanelContent>
          <PanelContainer>
            <Text fontSize='3xl' fontWeight="bold" ml="4" color="white">Heard</Text>
            <Dash />
          </PanelContainer>
        </PanelContent>
      </MainPanel>
    </ChakraProvider>
  );
};

export default Home;
