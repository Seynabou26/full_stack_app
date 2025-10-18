function Smartphone({ smartphone, onSelect, supprimer }) {
  const handleSupprimer = () => {
    if (window.confirm(`Voulez-vous vraiment supprimer "${smartphone.nom}" ?`)) {
      supprimer(smartphone.id); 
    }
  };

  return (
    <tr className="hover:bg-gray-100 transition-all duration-200">
      <td className="py-3 px-4 font-medium text-gray-700">{smartphone.id}</td>
      <td className="px-6 py-3 font-semibold text-gray-800">{smartphone.nom}</td>
      <td className="py-3 px-4 font-semibold text-gray-800">
        {smartphone.prix.toLocaleString()} FCFA
      </td>
      <td className="py-3 px-4 flex gap-2">
        <button
          onClick={() => onSelect(smartphone)}
          className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-1 rounded-lg shadow-md transition-colors font-medium"
        >
          Voir
        </button>
        <button
          onClick={handleSupprimer}
          className="bg-red-600 hover:bg-red-700 text-white px-4 py-1 rounded-lg shadow-md transition-colors font-medium"
        >
          Supprimer
        </button>
      </td>
    </tr>
  );
}

export default Smartphone;