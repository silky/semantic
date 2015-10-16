final class DiffTests: XCTestCase {
	override static func setUp() {
		sranddev()
	}

	typealias Term = RangedTerm.Term
	typealias Diff = Free<String, Patch<Term>>

	let interpreter = Interpreter<Term>(equal: ==, comparable: const(true), cost: Diff.sum(const(1)))

	func testEqualTermsProduceIdentityDiffs() {
		property("equal terms produce identity diffs") <- forAll { (term: RangedTerm) in
			Diff.sum(const(1))(self.interpreter.run(term.term, term.term)) == 0
		}
	}

	func testEqualityIsReflexive() {
		property("equality is reflexive") <- forAll { (diff: RangedDiff) in
			Free.equals(ifPure: Patch.equals(Cofree.equals(annotation: ==, leaf: ==)), ifRoll: ==)(diff.diff, diff.diff)
		}
	}
}


@testable import Doubt
import Prelude
import SwiftCheck
import XCTest
