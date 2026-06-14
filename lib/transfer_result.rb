# frozen_string_literal: true

# Records whether a transfer succeeded or failed, and why.
TransferResult = Struct.new(:transfer, :success, :error_message) do
  def success?
    success
  end

  def failure?
    !success
  end

  def to_s
    if success?
      "✓ #{transfer}"
    else
      "✗ #{transfer} — #{error_message}"
    end
  end
end
