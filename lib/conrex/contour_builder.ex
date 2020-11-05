defmodule Conrex.ContourBuilder do
  @moduledoc false

  @typep point :: {number, number}
  @typep segment :: {point, point}
  @typep sequence :: [point] # list of connected points
  @typep sequence_list :: [sequence] # collection of disconnected sequences

  @spec build_rings([segment]) :: sequence_list
  def build_rings(segments) do
    segments
    |> Enum.reduce([], &add_segment/2)
    |> Enum.map(&close_ring/1)
  end

  # Takes each segment in a list and uses it to extend a sequence of points.
  # If one segment point matches the head or tail of a sequence, the sequence is
  # extended with the other segment point. If both points match different
  # sequences, the sequences are joined. If neither match, the two points are
  # added as a new sequence.
  defp add_segment({pt_a, pt_b} = segment, sequences) do
    case find_segment_matches(segment, sequences) do
      # no match, add new sequence
      {{nil, false}, {nil, false}} ->
        [new_sequence(segment) | sequences]

      # A matched, extend with B
      {{sequence, should_prepend}, {nil, false}} ->
        replace_sequence(sequences, sequence, extend_sequence(sequence, pt_b, should_prepend))

      # B matched, extend with A
      {{nil, false}, {sequence, should_prepend}} ->
        replace_sequence(sequences, sequence, extend_sequence(sequence, pt_a, should_prepend))

      # both matched, join sequences
      {match_a, match_b} ->
        join_sequences(sequences, match_a, match_b)
    end
  end

  defp find_segment_matches(segment, sequences) do
    initial_matches = {{nil, false}, {nil, false}}
    Enum.reduce(sequences, initial_matches, fn sequence, matches -> match_segment(segment, sequence, matches) end)
  end

  # neither yet found, try both
  defp match_segment({pt_a, pt_b}, sequence, {{nil, false}, {nil, false}}), do: {match_point(pt_a, sequence), match_point(pt_b, sequence)}

  # A found, try to match B
  defp match_segment({_pt_a, pt_b}, sequence, {match_a, {nil, false}}), do: {match_a, match_point(pt_b, sequence)}

  # B found, try to match A
  defp match_segment({pt_a, _pt_b}, sequence, {{nil, false}, match_b}), do: {match_point(pt_a, sequence), match_b}

  # both found, do nothing
  defp match_segment(_, _, matches), do: matches

  defp match_point(point, sequence) do
    cond do
      List.first(sequence) == point -> {sequence, true}
      List.last(sequence) == point -> {sequence, false}
      true -> {nil, false}
    end
  end

  defp new_sequence({pt_a, pt_b}), do: [pt_a, pt_b]

  defp extend_sequence(sequence, point, true), do: [point | sequence]
  defp extend_sequence(sequence, point, false), do: sequence ++ [point]

  defp replace_sequence(sequences, old_sequence, sequence) do
    List.replace_at(sequences, Enum.find_index(sequences, fn seq -> seq == old_sequence end), sequence)
  end

  defp remove_sequence(sequences, sequence) do
    Enum.filter(sequences, fn seq -> seq != sequence end)
  end

  defp join_sequences(sequences, {seq_a, _}, {seq_b, _}) when seq_a == seq_b, do: sequences
  defp join_sequences(sequences, {seq_a, a_at_head}, {seq_b, b_at_head}) do
    case {a_at_head, b_at_head} do
      # seq A extends seq B
      {true, false} ->
        sequences
        |> replace_sequence(seq_b, seq_b ++ seq_a)
        |> remove_sequence(seq_a)

      # seq B extends seq A
      {false, true} ->
        sequences
        |> replace_sequence(seq_a, seq_a ++ seq_b)
        |> remove_sequence(seq_b)

      # head-head — reverse one and join
      {true, true} ->
        sequences
        |> replace_sequence(seq_b, Enum.reverse(seq_b) ++ seq_a)
        |> remove_sequence(seq_a)

      # tail-tail — reverse one and join
      {false, false} ->
        sequences
        |> replace_sequence(seq_b, seq_b ++ Enum.reverse(seq_a))
        |> remove_sequence(seq_a)
    end
  end

  defp close_ring(sequence) do
    sequence ++ [hd sequence]
  end

end
