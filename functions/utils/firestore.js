const admin = require('firebase-admin');

function cleanBookingDetails(details) {
  if (!details.selectedRooms) return details;
  return {
    ...details,
    selectedRooms: details.selectedRooms.map(room => {
      const { reviews, imageUrls, videoUrls, ...rest } = room;
      return rest;
    })
  };
}

async function findDocumentWithPrefix(reference, db) {
  const prefixMapping = {
    'B-': { type: 'booking', collection: 'bookings' },
    'F-': { type: 'food_order', collection: 'service_orders' },
    'G-': { type: 'gym_session', collection: 'service_orders' },
    'P-': { type: 'pool_session', collection: 'service_orders' },
    'L-': { type: 'laundry_service', collection: 'service_orders' },
    'C-': { type: 'concierge_request', collection: 'concierge_requests' },
  };
  
  for (const [prefix, config] of Object.entries(prefixMapping)) {
    const prefixedReference = `${prefix}${reference}`;
    
    try {
      const doc = await db.collection(config.collection).doc(prefixedReference).get();
      if (doc.exists) {
        let transactionType = config.type;
        
        if (config.collection === 'service_orders') {
          const serviceType = doc.data().serviceType;
          const serviceTypeMap = {
            'food_delivery': 'food_order',
            'gym': 'gym_session',
            'swimming_pool': 'pool_session',
            'spa': 'spa_session',
            'laundry_service': 'laundry_service',
          };
          transactionType = serviceTypeMap[serviceType] || transactionType;
        }
        
        return {
          actualReference: prefixedReference,
          transactionType: transactionType,
          orderDetails: doc.data(),
          userEmail: doc.data().userEmail || ''
        };
      }
    } catch (error) {
      continue;
    }
  }
  
  return {
    actualReference: reference,
    transactionType: 'booking',
    orderDetails: {},
    userEmail: ''
  };
}

module.exports = {
  cleanBookingDetails,
  findDocumentWithPrefix
};