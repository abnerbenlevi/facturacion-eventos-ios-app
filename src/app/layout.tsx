"use client";

import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { usePathname } from "next/navigation";
import "./globals.css";
import IOSTabBar from "@/components/IOSTabBar";

const inter = Inter({ subsets: ["latin"] });

// Note: Metadata export removed since this is now a client component
// The metadata will be handled via next/head in individual pages

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();
  
  // Don't show tab bar on login and register pages
  const hideTabBar = pathname === "/" || pathname === "/register";

  return (
    <html lang="es">
      <head>
        <title>iOS App - Facturación y Eventos</title>
        <meta name="description" content="Aplicación web optimizada para iPhone con sistema de facturación y eventos" />
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="iOS App" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="theme-color" content="#ffffff" />
        <meta name="format-detection" content="telephone=no" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
      </head>
      <body className={`${inter.className} antialiased`}>
        <div className="min-h-screen bg-gray-50">
          <div className="max-w-sm mx-auto bg-white min-h-screen relative overflow-hidden">
            {/* Main content with proper spacing for tab bar */}
            <div className={`min-h-screen ${!hideTabBar ? 'pb-20' : ''}`}>
              {children}
            </div>
            
            {/* iOS Tab Bar - only show on authenticated pages */}
            {!hideTabBar && <IOSTabBar />}
          </div>
        </div>
      </body>
    </html>
  );
}
