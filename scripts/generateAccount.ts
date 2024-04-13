import { ethers } from 'ethers';
import * as csv from 'csv-writer';

interface Address {
    id: number;
    address: string;
    amount: number;
}

async function generateAccountsData() {
    const addresses: Address[] = [];
    let amount = 10000;

    for (let i = 0; i < 500; i++) {
        const address: Address = {
            id: i,
            address: `${ethers.Wallet.createRandom().address}`,
            amount
        };

        addresses.push(address);
    }

    return addresses;
}

async function saveAddressesToCSV(addresses: Address[], filePath: string) {
    const csvWriter = csv.createObjectCsvWriter({
        path: filePath,
        header: [
            { id: 'id', title: 'ID' },
            { id: 'address', title: 'Address' },
            { id: 'amount', title: 'Amount' }
        ]
    });

    csvWriter.writeRecords(addresses)
        .then(() => console.log('CSV file has been generated successfully.'))
        .catch((error) => console.error('Error while generating CSV file:', error));
}

const filePath = 'scripts/accounts.csv';
generateAccountsData().then((data) => {
    saveAddressesToCSV(data, filePath).catch(console.error);
}).catch((error) => {
    console.error('Error while generating CSV file:', error);
})
