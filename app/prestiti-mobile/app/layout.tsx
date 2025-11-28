import type { Metadata } from "next";
import "./globals.css";
import ThemeRegistry from './ThemeRegistry';

export const metadata: Metadata = {
  title: "Prestiti Interbibliotecari - Biblioteca Rete",
  description: "App mobile per la registrazione dei prestiti interbibliotecari",
  viewport: "width=device-width, initial-scale=1, maximum-scale=1",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="it">
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
      </head>
      <body>
        <ThemeRegistry>
          {children}
        </ThemeRegistry>
      </body>
    </html>
  );
}
