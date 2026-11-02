package sample.app

import io.github.aryapreetam.parikshan.E2ETestLifecycle
import io.github.aryapreetam.parikshan.e2eTest
import kotlin.test.Test

class SampleIntegrationTest : E2ETestLifecycle {

  @Test
  fun testFibonacciCalculationFlow() = e2eTest {
    // 1. Assert initial UI elements are visible
    assertVisible("app_title")
    assertVisible("placeholder")

    // 2. Click and input number into text field
    click("number_input")
    input("number_input", "5")

    // 3. Verify calculated fibonacci result appears with correct sequence
    assertVisible("result_text")
    assertContains("result_text", "First 5 fibonacci numbers=0, 1, 1, 2, 3")
  }
}

