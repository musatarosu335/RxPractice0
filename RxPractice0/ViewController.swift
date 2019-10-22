//
//  ViewController.swift
//  RxPractice0
//
//  Created by 坂江顕太朗 on 2019/10/19.
//  Copyright © 2019 musatarosu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum State: Int {
    case useButton
    case useTextField
}

class ViewController: UIViewController {
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var stateSegmentControl: UISegmentedControl!
    @IBOutlet weak var freeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var greetingButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    // 初期化時の初期値の設定
    let lastSelectedGreeting: BehaviorRelay<String> = BehaviorRelay(value: "こんにちは")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 「名前」の入力フィールドにおいて、テキスト入力のイベントを観測対象にする
        let nameObservable: Observable<String?> = nameTextField.rx.text.asObservable()
        
        // 「自由入力」の入力フィールドにおいて、テキスト入力のイベントを観測対象にする
        let freeObservable: Observable<String?> = freeTextField.rx.text.asObservable()
        
        // (CombineLatest)「名前」と「自由入力」それぞれの直近の最新値同士を結合する
        let freewordWithNameObservable: Observable<String?> = Observable.combineLatest(
            nameObservable,
            freeObservable
        ) { (string1: String?, string2: String?) in
            return string1! + string2!
        }
        
        // (bind)イベントのプロパティを接続する　＊bindの引数内に表示対象のUIパーツを設定
        // (DisposeBag)購読状態からの解放を行う
        freewordWithNameObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
        
        // セグメントコントロールにおいて、値変化のイベントを観測対象にする
        let segmentedControlObservable: Observable<Int> = stateSegmentControl.rx.value.asObservable()
        
        // セグメントコントロールの値変化を検知して、その状態に対応するenumの値を返す
        // (map)別の要素へ変換　＊IntからStateへ変換
        let stateObservable: Observable<State> = segmentedControlObservable.map { (selectedIndex: Int) -> State in
            return State(rawValue: selectedIndex)!
        }
        
        // enumの値の変化を検知して、テキストフィールドが編集を受け付ける状態かを返す
        // (map)別の要素に変換する　＊StateからBoolへ
        let greetingTextFieldEnabledObservable: Observable<Bool> = stateObservable.map { (state: State) -> Bool in
            return state == .useTextField
        }
        
        // (bind)イベントのプロパティを接続する　＊bindの引数内に表示対象のUIパーツを設定
        // (DisposeBag)観測状態からの解放を行う
        greetingTextFieldEnabledObservable.bind(to: freeTextField.rx.isEnabled).disposed(by: disposeBag)
        
        // テキストフィールドが編集を受け付ける状態かを検知して、ボタンが選択可能かを返す
        // (map)別の要素に変換する　＊BoolからBoolへ変換
        let buttonEnabledObservable: Observable<Bool> = greetingTextFieldEnabledObservable.map { (greetingEnabled: Bool) -> Bool in
            return !greetingEnabled
        }
        
        /* ボタンに関する処理 START */
        // (bind)イベントのプロパティを接続する　＊bindの引数内に表示対象のUIパーツを設定する
        // (DisposeBag)観測状態からの解放を行う
        buttonEnabledObservable.bind(to: greetingButton.rx.isEnabled).disposed(by: disposeBag)
        
        // メンバ変数: lastSelectedGreetingにボタンのタイトル名を渡す
        // (subscribe)イベントが発生した場合にイベントのステータスに応じて処理を行う
        /*
        greetingButton.rx.tap.subscribe(onNext: { (nothing: Void) in
            let buttonTitle = self.greetingButton.currentTitle
            self.lastSelectedGreeting.value = buttonTitle!
            // let testTitle = self.greetingButton.currentTitle!
            // self.greetingButton.currentTitle = title
        }).addDisposableTo(disposeBag)
         */
        /* ボタンに関する処理 END */
        
        // 最終的な挨拶文章のイベント
        // (combineLatest)現在入力ないしは選択がされている項目を全て結合する
        let finalGreetingObservable: Observable<String> = Observable.combineLatest(stateObservable, freeObservable, nameObservable) { (state: State, freeword: String?, name: String?) -> String in
            switch state {
                case .useTextField:
                    return freeword! + name!
                case .useButton:
                    return "こんにちは！" + name!
            }
        }
        
        // 最終的な挨拶文章のイベント
        // (bind)イベントのプロパティ接続をする　＊最終的な挨拶文章を表示する
        // (DisposeBag)購読状態からの解放を行う
        finalGreetingObservable.bind(to: greetingLabel.rx.text).disposed(by: disposeBag)
    }


}

