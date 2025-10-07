package sample.app

import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.runComposeUiTest
import fiblib.getFibonacciNumbers
import kotlin.test.Test

class SampleUITest {

  @OptIn(ExperimentalTestApi::class)
  @Test
  fun sampleUiTest() = runComposeUiTest {
    setContent { App() }
    //onNodeWithText("Click me!").performClick()
    onNodeWithText("getFibonacciNumbers(7)=${getFibonacciNumbers(7).joinToString(", ")}").assertExists()
  }
}