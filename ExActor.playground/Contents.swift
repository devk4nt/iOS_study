
actor BankAccount {
    private var balance: Int = 0
    
    func deposit(_ input: Int) {
        balance += input
        Self.log("입금 완료: \(input)원, 현재 잔액: \(balance)원")
    }
    
    func withdraw(_ output: Int) {
        balance -= output
        Self.log("출금 완료: \(output)원, 현재 잔액: \(balance)원")
    }
    
    func getBalance() -> Int {
        return balance
    }
    
    nonisolated private static func log(_ message: String) {
        print("[BankAccount]", message)
    }
    
    nonisolated static func bankInfo() {
        print("은행 시스템 v1.0")
    }
}


let account = BankAccount()

await account.deposit(1000)
await account.withdraw(300)

print("최종 잔액", await account.getBalance())

BankAccount.bankInfo()
