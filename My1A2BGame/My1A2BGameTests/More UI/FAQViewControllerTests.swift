//
//  FAQViewControllerTests.swift
//  My1A2BGameTests
//
//  Created by Ming-Ta Yang on 2021/10/22.
//  Copyright © 2021 Ming-Ta Yang. All rights reserved.
//

import XCTest
import My1A2BGame

class FAQViewControllerTests: XCTestCase {
    
    func test_loadView_rendersEmptyListOnEmptyTableModel() {
        let sut = makeSUT(questions: [])
        
        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [])
    }
    
    func test_loadView_rendersQuestionsAndAnswers() {
        let question = Question(content: "a piece of content", answer: "an answer")
        let anotherQuestion = Question(content: "another piece ofcontent", answer: "another answer")
        let sut = makeSUT(questions: [question, anotherQuestion])

        sut.loadViewIfNeeded()
        
        assertThat(sut, isRendering: [question, anotherQuestion])
    }
    
    func test_loadView_allQuestionsUnfolded() {
        let sut = makeSUT()
        
        sut.loadViewIfNeeded()
        
        for section in 0..<sut.numberOfRenderedQuestionViews() {
            XCTAssertNotEqual(sut.heightForQuestion(at: section), 0.0)
        }
    }
    
    func test_loadView_rendersQuestionWithFoldingIndicator() {
        let question = anyQuestion()
        let sut = makeSUT(questions: [question])
        
        sut.loadViewIfNeeded()
        
        let imageView = try? XCTUnwrap(sut.question(at: 0)?.accessoryView as? UIImageView)
        XCTAssertEqual(imageView?.image?.pngData(), UIImage(named: "baseline_keyboard_arrow_left_black_18pt")?.pngData())
    }
    
    func test_onTapQuestion_controlsFoldingOfAnswer() {
        let question = anyQuestion()
        let sut = makeSUT(questions: [question])
        
        sut.loadViewIfNeeded()
        
        for section in 0..<sut.numberOfRenderedAnswerViews() {
            XCTAssertEqual(sut.heightForAnswer(at: section), 0.0, "Expect answer to be folded upon view load")
        }
        
        sut.simulateTappingQuestion(at: 0)
        XCTAssertNotEqual(sut.heightForAnswer(at: 0), 0.0, "Expect answer to be collpased upon tapping the question")
        
        sut.simulateTappingQuestion(at: 0)
        XCTAssertEqual(sut.heightForAnswer(at: 0), 0.0, "Expect answer to be folded again upon another tap on the question")
    }
    
    func test_onTapQuestion_rendersFoldingIndicator() {
        let question = anyQuestion()
        let sut = makeSUT(questions: [question])
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.foldingIndicatorView(at: 0)?.transform, .identity, "Expect the indicator to be pointing leftward upon view load")
        
        sut.simulateTappingQuestion(at: 0)
        XCTAssertEqual(sut.foldingIndicatorView(at: 0)?.transform, .init(rotationAngle: CGFloat(-Float.pi / 2)), "Expect the indicator to be pointing downward after tapping the question")
        
        sut.simulateTappingQuestion(at: 0)
        XCTAssertEqual(sut.foldingIndicatorView(at: 0)?.transform, .identity, "Expect the indicator to be back to pointing leftward after tapping the question again")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(questions: [Question] = [], file: StaticString = #filePath, line: UInt = #line) -> FAQViewController {
        let sut = FAQViewController(tableModel: questions)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func assertThat(_ sut: FAQViewController, isRendering questions: [Question], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedQuestionViews() == questions.count else {
            return XCTFail("Expected \(questions.count) questions, got \(sut.numberOfRenderedQuestionViews()) instead.", file: file, line: line)
        }

        questions.enumerated().forEach { section, question in
            assertThat(sut, hasViewConfiguredFor: question, at: section)
        }
    }

    private func assertThat(_ sut: FAQViewController, hasViewConfiguredFor question: Question, at section: Int, file: StaticString = #filePath, line: UInt = #line) {
        let questionCell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: section))
        let answerCell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: 1, section: section))
        XCTAssertEqual(questionCell?.textLabel?.text, question.content, "Expected the question content to be \(question.content) for question at section (\(section))", file: file, line: line)
        XCTAssertEqual(answerCell?.textLabel?.text, question.answer, "Expected the answer to be \(question.answer) for question at section (\(section))", file: file, line: line)
    }
}

private extension FAQViewController {
    func numberOfRenderedQuestionViews() -> Int {
        tableView.numberOfSections
    }
    
    func numberOfRenderedAnswerViews() -> Int {
        numberOfRenderedQuestionViews()
    }

    func heightForQuestion(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: questionRow, section: section))
    }
    
    func heightForAnswer(at section: Int) -> CGFloat? {
        tableView.delegate?.tableView?(tableView, heightForRowAt: IndexPath(row: answerRow, section: section))
    }
    
    func question(at section: Int) -> UITableViewCell? {
        tableView.cellForRow(at: IndexPath(row: questionRow, section: section))
    }
    
    func simulateTappingQuestion(at section: Int) {
        tableView.delegate?.tableView?(tableView, didSelectRowAt: IndexPath(row: questionRow, section: section))
    }
    
    func foldingIndicatorView(at section: Int) -> UIView? {
        question(at: section)?.accessoryView
    }
    
    private var questionRow: Int { 0 }
    
    private var answerRow: Int { 1 }
}

private func anyQuestion() -> Question {
    .init(content: "any content", answer: "any answer")
}
