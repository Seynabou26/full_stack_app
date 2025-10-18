import Smartphone from "./Smartphone.jsx";

function SmartphoneList({ smartphones, onSelect, supprimer, onAdd }) {
  return (
    <div className="p-6 bg-gray-50 min-h-screen">

      {/* Message si la liste est vide */}
      {smartphones.length === 0 ? (
        <p className="text-center text-gray-500 mb-4">
          Aucun smartphone disponible. Cliquez sur "Ajouter" pour en créer un.
        </p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full bg-white rounded-xl shadow-lg overflow-hidden border border-gray-200">
            <thead className="bg-gray-100">
              <tr>
                <th className="px-6 py-3 text-left text-gray-700 font-semibold uppercase tracking-wider border-b border-gray-200">
                  ID
                </th>
                <th className="px-6 py-3 text-left text-gray-700 font-semibold uppercase tracking-wider border-b border-gray-200">
                  Nom
                </th>
                <th className="px-6 py-3 text-left text-gray-700 font-semibold uppercase tracking-wider border-b border-gray-200">
                  Prix
                </th>
                <th className="px-6 py-3 text-left text-gray-700 font-semibold uppercase tracking-wider border-b border-gray-200">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {smartphones.map((phone) => (
                <Smartphone
                  key={phone.id || phone._id}
                  smartphone={phone}
                  onSelect={onSelect}
                  supprimer={supprimer}
                />
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}

export default SmartphoneList;