# Store application - front

1. Copy the source code to the server
2. Install the dependencies
```bash
npm install
```
3. Initiate database (make sure .env is correct and valid)
```bash
npx prisma db push
```
4. Run the server in detached mode (make sure to adapt the env with DATABASE_URL)
5. Want to have an admin account, run the seeder
```bash
npx prisma db seed
```

## What to do
- [ ] Add a Dockerfile
- [ ] Add a CI/CD pipeline
    - [ ] Build the application
    - [ ] Run the tests (if applicable)
    - [ ] Deploy the application on cloud
