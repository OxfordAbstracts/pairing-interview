import React, { useState, useEffect } from 'react';

const Table = () => {
  const [abstracts, setAbstracts] = useState([]);

  useEffect(() => {
    fetchAbstracts();
  }, []);

  const fetchAbstracts = async () => {
    try {
      const response = await fetch('http://localhost:3000/abstracts');
      const data = await response.json();
      setAbstracts(data);
    } catch (error) {
      console.error('Error fetching abstracts:', error);
    }
  };

  return (
    <div className="container mx-auto p-8">
      <table className="table-auto">
        <thead>
          <tr>
            <th className="px-4 py-2">Title</th>
            <th className="px-4 py-2">Category</th>
          </tr>
        </thead>
        <tbody>
          {abstracts.map((abstract) => (
            <tr key={abstract.id}>
              <td className="border px-4 py-2">{abstract.title}</td>
              <td className="border px-4 py-2">{abstract.category}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Table;