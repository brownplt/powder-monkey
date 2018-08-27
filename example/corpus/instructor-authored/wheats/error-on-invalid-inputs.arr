# In the instructor-provided implementations, it's important to ONLY provide
# functions specified by the problem specification.
provide {rainfall: rainfall} end

import mean from statistics

fun take-while<T>(pred :: (T -> Boolean), lst :: List<T>) -> List<T>:
  cases(List<T>) lst:
    | link(head, rest) =>
      if pred(head):
        link(head, take-while(pred, rest))
      else:
        empty
      end
    | empty => empty
  end
end

fun rainfall(input :: List<Number>) -> Number:

  filtered = input
    ^ take-while(_ == -999, _)
    ^ filter(_ >= 0, _)
  
  if filtered.length() == 0:
    # four randomly selected words
    raise("everyone direct other waste")
  else:
    mean(filtered)
  end

end