import Principal "mo:base/Principal";

import Ledger "../modules/ledger";
shared ({ caller = master }) actor class God() = this {

	/////////////
	// LEDGER //
	////////////
	stable let ledgerState = Ledger.State.V1.initRoot(Principal.fromActor(this));
	let ledger = Ledger.Root(ledgerState);

	public shared ({ caller }) func transact(
		action : Ledger.Action
	) : async () {
		switch (action) {
			case (#transfer(transfer)) {
				await* ledger.transfer(caller, transfer);
			};
			case (#mint(mint)) {
				await* ledger.mint(caller, mint);
			};
		};
	};
};
