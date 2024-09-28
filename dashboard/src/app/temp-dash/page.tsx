// src/components/Dashboard.js
import React from 'react';
import './page.css';

const Dashboard = () => {
  return (
    <>
   
<div>
   <nav className="bg-white border-b border-gray-200 fixed z-30 w-full">
      <div className="px-3 py-3 lg:px-5 lg:pl-3">
         <div className="flex items-center justify-between">
            <div className="flex items-center justify-start">
               <button id="toggleSidebarMobile" aria-expanded="true" aria-controls="sidebar" className="lg:hidden mr-2 text-gray-600 hover:text-gray-900 cursor-pointer p-2 hover:bg-gray-100 focus:bg-gray-100 focus:ring-2 focus:ring-gray-100 rounded">
                  <svg id="toggleSidebarMobileHamburger" className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                     <path fill-rule="evenodd" d="M3 5a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zM3 10a1 1 0 011-1h6a1 1 0 110 2H4a1 1 0 01-1-1zM3 15a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path>
                  </svg>
                  <svg id="toggleSidebarMobileClose" className="w-6 h-6 hidden" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                     <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                  </svg>
               </button>
               <a href="#" className="text-xl font-bold flex items-center lg:ml-2.5">
               <img src="https://demo.themesberg.com/windster/images/logo.svg" className="h-6 mr-2" alt="Windster Logo"/>
               <span className="self-center whitespace-nowrap">Windster</span>
               </a>
               
            </div>
            <div className="flex items-center">
               <button id="toggleSidebarMobileSearch" type="button" className="lg:hidden text-gray-500 hover:text-gray-900 hover:bg-gray-100 p-2 rounded-lg">
                  <span className="sr-only">Search</span>
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
                     <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path>
                  </svg>
               </button>
               <div className="hidden lg:flex items-center">
                  <span className="text-base font-normal text-gray-500 mr-5">Open source</span>
                  <div className="-mb-1">
                     <a className="github-button" href="#" data-color-scheme="no-preference: dark; light: light; dark: light;" data-icon="octicon-star" data-size="large" data-show-count="true" aria-label="Star themesberg/windster-tailwind-css-dashboard on GitHub">Star</a>
                  </div>
               </div>
               <a href="#" className="hidden sm:inline-flex ml-5 text-white bg-cyan-600 hover:bg-cyan-700 focus:ring-4 focus:ring-cyan-200 font-medium rounded-lg text-sm px-5 py-2.5 text-center items-center mr-3">
                  <svg className="svg-inline--fa fa-gem -ml-1 mr-2 h-4 w-4" aria-hidden="true" focusable="false" data-prefix="fas" data-icon="gem" role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
                     <path fill="currentColor" d="M378.7 32H133.3L256 182.7L378.7 32zM512 192l-107.4-141.3L289.6 192H512zM107.4 50.67L0 192h222.4L107.4 50.67zM244.3 474.9C247.3 478.2 251.6 480 256 480s8.653-1.828 11.67-5.062L510.6 224H1.365L244.3 474.9z"></path>
                  </svg>
                  Upgrade to Pro
               </a>
            </div>
         </div>
      </div>
   </nav>
   
   <div className="flex overflow-hidden bg-white pt-16">
      <div className="bg-gray-900 opacity-50 hidden fixed inset-0 z-10" id="sidebarBackdrop"></div>
      <div id="main-content" className="h-full w-full bg-gray-50 relative overflow-y-auto lg:ml-64">
         <main>
            <div className="pt-6 px-4">
               <div className="w-full grid grid-cols-1 xl:grid-cols-2 2xl:grid-cols-3 gap-4">

                  <div className="bg-white shadow rounded-lg p-4 sm:p-6 xl:p-8  2xl:col-span-2">
                     <div className="flex items-center justify-between mb-4">
                        <div className="flex-shrink-0">
                           <h3 className="text-2xl font-bold text-gray-900 mb-2">Live Feed</h3>
                        </div>
                        <div className="status-button">
                           <h2>Online</h2>
                        </div>
                     </div>
                     <div className="w-4/5">
                        <img src="https://pm1.aminoapps.com/7544/d523bfe83733e68a0f353744a72131efd890b496r1-500-670v2_hq.jpg"/>
                     </div>
                  </div>
                  
                   
                  <div className="w-full max-w-md bg-white rounded-lg shadow-md overflow-hidden">
                     <div className="p-4">
                           <h1 className="text-xl font-bold mb-4">Chat</h1>
                           <div className="overflow-auto h-64 border-b border-gray-300 mb-4" id="chat">
                           </div>
                     </div>
                     <div className="flex p-4 border-t border-gray-300">
                           <input type="text" id="messageInput" placeholder="Type your message..." className="flex-1 border border-gray-300 rounded-lg px-4 py-2 mr-2"/>
                           <button id="sendButton" className="bg-blue-500 text-white rounded-lg px-4 py-2">Send</button>
                     </div>
                  </div>
               </div>
               
               <div className="grid grid-cols-1 2xl:grid-cols-2 xl:gap-4 my-4">
                  
                  
               </div>
            </div>
         </main>
         
         
      </div>
   </div>
</div>
</>
  );
  };

export default Dashboard;