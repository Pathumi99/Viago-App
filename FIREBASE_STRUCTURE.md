# ViaGo Firebase Structure & Workflow

## 📊 Firebase Collections Overview

### 1. **users** Collection
Stores user information for both riders and passengers.

```json
{
  "userId": {
    "name": "John Silva",
    "phone": "+94771234567",
    "userType": "rider", // or "passenger"
    "vehicleType": "Car", // only for riders
    "averageRating": 4.5,
    "numRatings": 23,
    "email": "john@example.com",
    "createdAt": "timestamp"
  }
}
```

### 2. **rider_routes** Collection
Stores available rides posted by riders.

```json
{
  "routeId": {
    "riderId": "userId",
    "from": "Colombo",
    "to": "Kandy",
    "departureDate": "timestamp",
    "departureTime": "08:00 AM",
    "vehicleType": "Car",
    "availableSeats": 3,
    "price": 1500.0,
    "notes": "Comfortable sedan, AC available",
    "isActive": true,
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

### 3. **passenger_requests** Collection
Stores passenger ride search requests.

```json
{
  "requestId": {
    "userId": "passengerId",
    "from": "Colombo Fort",
    "to": "Kandy City",
    "contact": "+94701111111",
    "name": "Saman Kumara",
    "startLat": 6.9320,
    "startLng": 79.8428,
    "endLat": 7.2906,
    "endLng": 80.6337,
    "departureDate": "timestamp",
    "departureTime": "08:00 AM",
    "vehicleType": "Car",
    "timestamp": "timestamp"
  }
}
```

### 4. **ride_requests** Collection
Stores actual ride requests from passengers to specific riders.

```json
{
  "rideRequestId": {
    "passengerId": "userId",
    "riderId": "userId",
    "passengerName": "Saman Kumara",
    "passengerPhone": "+94701111111",
    "startLocation": "Colombo",
    "endLocation": "Kandy",
    "startLat": 6.9320,
    "startLng": 79.8428,
    "endLat": 7.2906,
    "endLng": 80.6337,
    "departureDate": "timestamp",
    "departureTime": "08:00 AM",
    "vehicleType": "Car",
    "status": "pending", // pending, accepted, rejected, completed, cancelled
    "createdAt": "timestamp",
    "updatedAt": "timestamp",
    "acceptedAt": "timestamp", // optional
    "rejectedAt": "timestamp", // optional
    "completedAt": "timestamp" // optional
  }
}
```

### 5. **notifications** Collection
Stores notifications for users.

```json
{
  "notificationId": {
    "userId": "recipientId",
    "type": "ride_request", // ride_request, ride_update, promotion, system
    "title": "New Ride Request",
    "message": "You have a new ride request from John Doe",
    "rideRequestId": "rideRequestId", // optional
    "status": "pending", // pending, accepted, rejected
    "timestamp": "timestamp",
    "isRead": false,
    "icon": "directions_car_outlined"
  }
}
```

### 6. **reviews** Collection
Stores ride reviews and ratings.

```json
{
  "reviewId": {
    "rideId": "rideRequestId",
    "riderId": "userId",
    "passengerId": "userId",
    "rating": 4.5,
    "feedback": "Great driver, comfortable ride",
    "timestamp": "timestamp"
  }
}
```

## 🔄 Complete Workflow

### **Rider Workflow:**
1. **Rider Registration** → `users` collection
2. **Post a Ride** → `rider_routes` collection
3. **Receive Requests** → `ride_requests` collection + `notifications`
4. **Accept/Reject** → Update `ride_requests` + Create `notifications`
5. **Complete Ride** → Update `ride_requests` + Create `notifications`

### **Passenger Workflow:**
1. **Passenger Registration** → `users` collection
2. **Search for Ride** → `passenger_requests` collection
3. **View Available Rides** → Query `rider_routes` collection
4. **Send Ride Request** → `ride_requests` collection + `notifications`
5. **Receive Response** → `notifications` collection
6. **Rate Ride** → `reviews` collection

## 📱 Screen Navigation Flow

### **Rider Flow:**
```
RiderHomeScreen 
  ├── PostRide → RiderRouteScreen → rider_routes collection
  └── ViewRequests → RiderRequestsScreen → ride_requests collection
```

### **Passenger Flow:**
```
PassengerHomeScreen 
  ├── FindRide → PassengerRouteScreen 
  │                └── PassengerMapScreen → passenger_requests collection
  │                    └── MatchingRidersScreen → rider_routes query
  │                        └── SendRequest → ride_requests collection
  └── MyRequests → PassengerRequestsScreen → ride_requests query
```

## 🛠️ Key Services

### **RideService** (`lib/services/ride_service.dart`)
- `createRideRequest()` - Creates ride requests with notifications
- `acceptRideRequest()` - Accepts ride requests
- `rejectRideRequest()` - Rejects ride requests
- `completeRide()` - Marks rides as completed
- `cancelRideRequest()` - Cancels ride requests

### **NotificationService** (`lib/services/notification_service.dart`)
- `createRideRequestNotification()` - Notifies riders of new requests
- `createRideResponseNotification()` - Notifies passengers of responses
- `createRideCompletedNotification()` - Notifies about ride completion

## 🚀 Getting Started

### **Test Data Creation:**
1. Navigate to "Matching Riders" screen
2. Click "Create Sample Riders (Test)" button
3. This creates:
   - 3 sample riders in `users` collection
   - 3 sample routes in `rider_routes` collection
   - 2 sample passenger requests in `passenger_requests` collection

### **Firebase Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Rider routes - riders can CRUD their own, passengers can read
    match /rider_routes/{routeId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.riderId;
    }
    
    // Passenger requests - passengers can CRUD their own
    match /passenger_requests/{requestId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Ride requests - involved parties can read/write
    match /ride_requests/{requestId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.passengerId || 
         request.auth.uid == resource.data.riderId);
    }
    
    // Notifications - users can read/write their own
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
    
    // Reviews - public read, authenticated write
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 📈 Status Tracking

### **Ride Request Statuses:**
- `pending` - Request sent, waiting for rider response
- `accepted` - Rider accepted the request
- `rejected` - Rider rejected the request
- `completed` - Ride completed successfully
- `cancelled` - Request cancelled by passenger

### **Notification Types:**
- `ride_request` - New ride request for riders
- `ride_update` - Status updates for passengers
- `promotion` - Promotional notifications
- `system` - System announcements

This structure ensures a complete ride-sharing workflow with proper data tracking and user notifications! 