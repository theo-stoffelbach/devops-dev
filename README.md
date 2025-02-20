# Store application

## Project Overview
This project contains the source code of store application.

On the `back` folder, you will find the source code of the API, developed with express and node.
On the `front` folder, you will find the source code of the front-end application, developed with Vue3.

## Installation

1. Clone the repository
2. Install the dependencies on each subfolder (back and front)
3. Create a `.env` file on the `back` folder with the following content:
```
DATABASE_URL=file:./file.db
JWT_SECRET=your_secret
BCRYPT_SALT_ROUNDS=10
```

### Run the back
1. Go to the `back` folder
2. Run the following command:
```bash
npx prisma generate dev
npm run start
```
3. API is exposed on `http://localhost:3000`

#### Run the tests
1. Go to the `back` folder
2. Run the following command:
```bash
npm run test
```

### Run the front
1. Go to the `front` folder
2. Make sure the .env file contains the good URL for the API
```bash
VITE_API_URL=http://localhost:3000
```
3. Run with the following command:
```bash
npm run dev
```

### Postman collection

A postman collection is available under the `docs` folder. You can import it directly on Postman to use it.

## Contributing
1. Fork the repository
2. Create a new branch (`git checkout -b feature-branch`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature-branch`)
5. Create a new Pull Request

## License
This project is licensed under the MIT License.

## Contact
For any inquiries, please contact [quentin.desbin@ynov.com](mailto:quentin.desbin@ynov.com).
