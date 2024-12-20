import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Text "mo:base/Text";

import Ledger "../modules/ledger";
shared ({ caller = creator }) actor class You(
	god : Principal,
	user : Principal
) = this {

	////////////
	// ADMIN //
	///////////

	private let admin = user;


	/////////////
	// LEDGER //
	////////////

	// We define a module and we can use it
	stable let ledgerState = Ledger.State.V1.initLeaf(god, Principal.fromActor(this));
	let ledger = Ledger.Leaf(ledgerState);

	////////////
	// GAME ///
	///////////

	stable var state : Text = "Player is off";

	public shared query ({ caller }) func getState() : async Text {
		assert (caller == admin);
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
		#transact : Ledger.Action;
	};

	public shared ({ caller }) func play(
		action : Action
	) : async Result.Result<(), Text> {
		assert (caller == admin);
		switch (action) {
			case (#transact(transaction)) {
				await* ledger.transact(transaction);
			};
		};
	};

};
