import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Error "mo:base/Error";
shared ({ caller = creator }) actor class You(
	god : Principal,
	admin : Principal,
	yourName : Text
) = this {

    ////////////
	// IDENTITY /
	///////////

    stable var name = yourName;

	////////////
	// GAME ///
	///////////

	stable var state : Text = "Player is off";

    public shared query ({ caller }) func getState() : async Text {
        assert(caller == admin);
        return state;  
    };

	public shared ({ caller }) func start() : async () {
		assert (caller == god or caller == admin);
		state := "Waiting for your next move";
	};

	public shared ({ caller }) func stop() : async () {
		assert (caller == god or caller == admin);
		state := "Player is off";
	};

    

    public type Action = {
        #transact : Transaction;
        #move;
    };

    public type Transaction = {
        #transfer: Transfer;
        #mint : Mint;
    };

    public type Transfer = {
        from : Principal;
        to : Principal;
        amount : Nat; 
    };

    public type Mint = {
        to : Principal;
        amount : Nat;
    };

    public type Ledger = actor {
        transfer : shared (transfer : Transfer) -> async ();
        mint : shared (mint : Mint) -> async ();
    };

   

	public shared ({ caller }) func play(
        action : Action
    ) : async Result.Result<(), Text> {
        assert(caller == admin);
        switch(action){
            case(#transact(transaction)){
                let ledger : Ledger = actor("bkyz2-fmaaa-aaaaa-qaaaq-cai");

                switch(transaction){
                    case(#transfer(transfer)){
                        try {
                            await ledger.transfer(transfer);
                            state := "You've just made a successful transfer";
                            return #ok();
                        } catch (e) {
                            return #err(Error.message(e));
                        };
                    };
                    case(#mint(mint)){  
                        try {
                            await ledger.mint(mint);
                             state := "You've successful minted $BOOT tokens!";
                            return #ok();
                        } catch (e) {
                            return #err(Error.message(e));
                        };
                    };
                };


            };
            case(_) {
                return #err("Not implemented yet!")
            };

        };


	};

};
