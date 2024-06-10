import React from "react";

function Home() {
  return (
    <div className="bg-gray-100">
      <header className="bg-white shadow">
        <nav className="container mx-auto px-4 py-2 flex items-center justify-between">
          <a href="/" className="text-xl font-bold text-gray-800">
            My Website
          </a>
          <ul className="flex space-x-4">
            <li>
              <a href="/" className="text-gray-600 hover:text-gray-800">
                Home
              </a>
            </li>
            <li>
              <a href="/about" className="text-gray-600 hover:text-gray-800">
                About
              </a>
            </li>
            <li>
              <a href="/contact" className="text-gray-600 hover:text-gray-800">
                Contact
              </a>
            </li>
          </ul>
        </nav>
      </header>
      <main className="container mx-auto px-4 py-8">
        <h1 className="text-4xl font-bold text-gray-800">
          Welcome to OA
        </h1>
        <p className="text-lg text-gray-600 mt-4">
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam
          auctor, nunc id ultricies aliquam, nunc nunc lacinia nunc, id
          tincidunt nunc nunc vitae mauris.
        </p>
      </main>
      <footer className="bg-gray-200 py-4">
        <div className="container mx-auto px-4">
          <p className="text-center text-gray-600">
            © 2022 My Website. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}

export default Home;
