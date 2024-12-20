import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Error "mo:base/Error";
import Map "mo:map/Map";
import {phash} "mo:map/Map";
shared ({ caller = master }) actor class God() = this {

    private let MAXIMUM_SUPPLY = 21_000_000;

    stable let ledger : Map.Map<Principal, Nat> = Map.new();

     public type Mint = {
        to : Principal;
        amount : Nat;
    };

    public shared ({ caller }) func mint(mint : Mint
    ) : async () {
        let {to; amount} = mint; 

        let toBalance = Option.get(Map.get<Principal,Nat>(ledger, phash, to), 0);
        if (toBalance + amount <= MAXIMUM_SUPPLY) {
            Map.set<Principal, Nat>(ledger, phash, to, toBalance + amount);
        } else {
            throw(Error.reject("Exceeds maximum supply"));
        }
    };

     public type Transfer = {
        from : Principal;
        to : Principal;
        amount : Nat; 
    };


    public shared ({ caller }) func transfer(transfer : Transfer
    ) : async () {
        assert(caller == transfer.from);

        let {to; from; amount} = transfer; 

        let fromBalance = Option.get(Map.get<Principal,Nat>(ledger, phash, from), 0);
        let toBalance = Option.get(Map.get<Principal,Nat>(ledger, phash, to), 0);

        if (fromBalance >= transfer.amount) {
            Map.set<Principal, Nat>(ledger, phash, from, fromBalance - amount);
            Map.set<Principal, Nat>(ledger, phash, to, toBalance + amount);
        } else {
            throw(Error.reject("Insufficient funds"));
        }
    };

    public shared query ({ caller }) func balance() : async Nat {
        let balance = Option.get(Map.get<Principal,Nat>(ledger, phash, caller), 0);
        return balance;
    };

    public query func getBalance(who : Principal) : async Nat {
        let balance = Option.get(Map.get<Principal,Nat>(ledger, phash, who), 0);
        return balance;
    };




}