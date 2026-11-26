//
//  NSSortDescriptorDemo.swift
//  SPiOSCommonP8
//
//  Created by Vijay Sachan on 25/11/26.
//

import Foundation
class NSSortDescriptorDemo{
    func demo(){
        sortNames()
    }
    let keyNo: String = "mNo"
    let keyAge: String = "mAge"
    let keyFirstName: String = "mFirstName"
    let keyLastName: String = "mLastName_Optional"
    let keyNickName: String = "mNickName_Transient"
    
    lazy var arrayRowData: [[String: Any]] = {
        let arrayOfDict: [[String: Any]] = [
            [keyNo: 1, keyAge: "2002-11-23", keyFirstName: "Aarav", keyLastName: "Sharma", keyNickName: "Avi"],
            [keyNo: 2, keyAge: "1995-11-23", keyFirstName: "Priya", keyLastName: "Patel", keyNickName: "Pihu"],
            [keyNo: 3, keyAge: "1998-11-23", keyFirstName: "Rohan", keyLastName: "Verma", keyNickName: "Ronny"],
            [keyNo: 4, keyAge: "1991-11-23", keyFirstName: "Ananya", keyLastName: "Nair", keyNickName: "Annie"],
            [keyNo: 5, keyAge: "2004-11-23", keyFirstName: "Kabir", keyLastName: "Mehta", keyNickName: "Kabbu"],
            [keyNo: 6, keyAge: "1997-11-23", keyFirstName: "Sneha", keyLastName: "Iyer", keyNickName: "Snehu"],
            [keyNo: 7, keyAge: "1986-11-23", keyFirstName: "Vikram", keyLastName: "Rao", keyNickName: "Vicky"],
            [keyNo: 8, keyAge: "1999-11-23", keyFirstName: "Meera", keyLastName: "Kulkarni", keyNickName: "Mira"],
            [keyNo: 9, keyAge: "1993-11-23", keyFirstName: "Arjun", keyLastName: "Desai", keyNickName: "AJ"],
            [keyNo: 10, keyAge: "2000-11-23", keyFirstName: "Diya", keyLastName: "Kapoor", keyNickName: "Didi"],

            // Extra rows for case, diacritic & locale sorting experiments
            [keyNo: 11, keyAge: "2001-05-12", keyFirstName: "aarav", keyLastName: "sharma", keyNickName: "avi2"],
            [keyNo: 12, keyAge: "1996-08-19", keyFirstName: "Áarav", keyLastName: "Álvarez", keyNickName: "Ávi"],
            [keyNo: 13, keyAge: "1994-03-04", keyFirstName: "Éva", keyLastName: "Öztürk", keyNickName: "Évi"],
            [keyNo: 14, keyAge: "1992-11-23", keyFirstName: "priya", keyLastName: "patel", keyNickName: "pihu2"]
        ]
        return arrayOfDict
    }()
    func sortNames() {
        let nsArray = arrayRowData as NSArray
        // 1. Default sort descriptor: ascending = true, no custom selector.
        // For strings, default comparison is case-sensitive and diacritic-sensitive.Uppercase comes before lowercase.
        let sort1 = NSSortDescriptor(key: keyFirstName, ascending: true)
        let sortedDefault = (nsArray.sortedArray(using: [sort1]) as? [[String: Any]]) ?? []
        print("Default sort:", sortedDefault.compactMap { $0[keyFirstName] as? String })
        // ["Aarav", "Ananya", "Arjun", "Áarav", "Diya", "Éva", "Kabir", "Meera", "Priya", "Rohan", "Sneha", "Vikram", "aarav", "priya"]

        // 2. Descending sort using reversedSortDescriptor (flips ascending: true -> false)
        if let sortDescending = sort1.reversedSortDescriptor as? NSSortDescriptor {
            let sortedDesc = (nsArray.sortedArray(using: [sortDescending]) as? [[String: Any]]) ?? []
            print("Descending sort:", sortedDesc.compactMap { $0[keyFirstName] as? String }) // ["priya", "aarav", "Vikram", "Sneha", "Rohan", "Priya", "Meera", "Kabir", "Éva", "Diya", "Áarav", "Arjun", "Ananya", "Aarav"]
        }

        // 3. Case-insensitive comparison selector: ignores A vs a, while keeping diacritic/accent distinctions
        let sortCaseInsensitive = NSSortDescriptor(
            key: keyFirstName,
            ascending: true,
            selector: #selector(NSString.caseInsensitiveCompare(_:))
        )
        let sortedCaseInsensitive = (nsArray.sortedArray(using: [sortCaseInsensitive]) as? [[String: Any]]) ?? []
        print("Case-insensitive sort:", sortedCaseInsensitive.compactMap { $0[keyFirstName] as? String }) // ["Aarav", "aarav", "Ananya", "Arjun", "Áarav", "Diya", "Éva", "Kabir", "Meera", "Priya", "priya", "Rohan", "Sneha", "Vikram"]

        // 4. Localized standard comparison selector: user-locale-aware, case-insensitive,
        // and natural/diacritic-friendly ordering (similar to Finder sorting)
        let sortLocalized = NSSortDescriptor(
            key: keyFirstName,
            ascending: true,
            selector: #selector(NSString.localizedStandardCompare(_:))
        )
        let sortedLocalized = (nsArray.sortedArray(using: [sortLocalized]) as? [[String: Any]]) ?? []
        print("Localized standard sort:", sortedLocalized.compactMap { $0[keyFirstName] as? String }) // ["aarav", "Aarav", "Áarav", "Ananya", "Arjun", "Diya", "Éva", "Kabir", "Meera", "priya", "Priya", "Rohan", "Sneha", "Vikram"]

        // 5. Multi-descriptor sort (tie-breaker): primary sort by mFirstName,
        // secondary sort by mNo ascending when two items compare as equal
        let sortByNo = NSSortDescriptor(key: keyNo, ascending: true)
        let sortedMulti = (nsArray.sortedArray(using: [sortLocalized, sortByNo]) as? [[String: Any]]) ?? []
        print(
            "Localized + mNo tie-breaker:",
            sortedMulti.map { item in
                let name = (item[keyFirstName] as? String) ?? ""
                let no = (item[keyNo] as? Int) ?? 0
                return "\(name)(#\(no))"
            }
        ) // ["aarav(#11)", "Aarav(#1)", "Áarav(#12)", "Ananya(#4)", "Arjun(#9)", "Diya(#10)", "Éva(#13)", "Kabir(#5)", "Meera(#8)", "priya(#14)", "Priya(#2)", "Rohan(#3)", "Sneha(#6)", "Vikram(#7)"]
    }
}
