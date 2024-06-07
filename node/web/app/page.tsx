import Image from "next/image";


export default function Home({ Component, pageProps }) {
  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <Component {...pageProps} />
    </main>
  )
}