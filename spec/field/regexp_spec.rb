# frozen_string_literal: true

require_relative "shared_examples"

RSpec.describe MemDB::Field::Regexp do
  let(:field) { described_class.new(:text) }

  it_behaves_like "field", "exact single match", {
    matching: {text: '\\Afood\\z'},
    query: {text: "food"},
    expect: true
  }

  it_behaves_like "field", "match multiline strings", {
    matching: {text: '\\A.*food.*\\z'},
    query: {text: "\r\nfood\r\n"},
    expect: true
  }

  it_behaves_like "field", "exact single match to multiquery", {
    matching: {text: '\\Afood\\z'},
    query: {text: ["games", "food"]},
    expect: true
  }

  it_behaves_like "field", "no exact single match", {
    matching: {text: '\\Afood\\z'},
    query: {text: "games"},
    expect: false
  }

  it_behaves_like "field", "multiple match", {
    matching: {text: ['\\Afood\\z', '\\Aclothes\\z']},
    query: {text: "food"},
    expect: true
  }

  it_behaves_like "field", "multiple match to multiquery", {
    matching: {text: ['\\Afood\\z', '\\Aclothes\\z']},
    query: {text: ["games", "food"]},
    expect: true
  }

  it_behaves_like "field", "no multiple match", {
    matching: {text: ['\\Afood\\z', '\\Aclothes\\z']},
    query: {text: "games"},
    expect: false
  }

  it_behaves_like "field", "match by prefix", {
    matching: {text: "\\Aabc.*\\z"},
    query: {text: "abc"},
    expect: true
  }

  it_behaves_like "field", "match by prefix", {
    matching: {text: "\\Aabc.*\\z"},
    query: {text: "abc9"},
    expect: true
  }

  it_behaves_like "field", "match by suffix", {
    matching: {text: "\\A.*abc\\z"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "match by suffix", {
    matching: {text: "\\A.*abc\\z"},
    query: {text: "abc"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "\\A.*abc.*\\z"},
    query: {text: "abc"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "\\A.*abc.*\\z"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "\\A.*abc.*\\z"},
    query: {text: "abc9"},
    expect: true
  }

  it_behaves_like "field", "match by sequence", {
    matching: {text: "\\A.*abc.*\\z"},
    query: {text: "0abc9"},
    expect: true
  }

  it_behaves_like "field", "pattern is longer than text", {
    matching: {text: "\\Aabcd.*\\z"},
    query: {text: "abc"},
    expect: false
  }

  it_behaves_like "field", "pattern mismatched by suffix", {
    matching: {text: "\\A.*0abc\\z"},
    query: {text: "abc"},
    expect: false
  }

  it_behaves_like "field", "pattern match", {
    matching: {text: "\\A0.*abc\\z"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "pattern match 2", {
    matching: {text: "\\A0[1-4]+abc\\z"},
    query: {text: "01234abc"},
    expect: true
  }

  it_behaves_like "field", "pattern match 3", {
    matching: {text: "\\A.*0.*abc\\z"},
    query: {text: "0abc"},
    expect: true
  }

  it_behaves_like "field", "pattern match 4", {
    matching: {text: "\\A.*0.*abc\\z"},
    query: {text: "-101abc"},
    expect: true
  }

  context "when text case mismatch" do
    it_behaves_like "field", "exact single match", {
      matching: {text: '\\AfoOD\\z'},
      query: {text: "FOod"},
      expect: false
    }

    it_behaves_like "field", "match multiline strings", {
      matching: {text: '\\A.*foOD.*\\z'},
      query: {text: "\r\nFOod\r\n"},
      expect: false
    }

    it_behaves_like "field", "exact single match to multiquery", {
      matching: {text: '\\AfoOD\\z'},
      query: {text: ["games", "FOod"]},
      expect: false
    }

    it_behaves_like "field", "multiple match", {
      matching: {text: ['\\AfoOD\\z', '\\Aclothes\\z']},
      query: {text: "FOod"},
      expect: false
    }

    it_behaves_like "field", "multiple match to multiquery", {
      matching: {text: ['\\AfoOD\\z', '\\Aclothes\\z']},
      query: {text: ["games", "FOod"]},
      expect: false
    }

    it_behaves_like "field", "match by prefix", {
      matching: {text: "\\AaBC.*\\z"},
      query: {text: "ABc"},
      expect: false
    }

    it_behaves_like "field", "match by prefix", {
      matching: {text: "\\AaBC.*\\z"},
      query: {text: "ABc9"},
      expect: false
    }

    it_behaves_like "field", "match by suffix", {
      matching: {text: "\\A.*aBC\\z"},
      query: {text: "0ABc"},
      expect: false
    }

    it_behaves_like "field", "match by suffix", {
      matching: {text: "\\A.*aBC\\z"},
      query: {text: "ABc"},
      expect: false
    }

    it_behaves_like "field", "match by sequence", {
      matching: {text: "\\A.*aBC.*\\z"},
      query: {text: "ABc"},
      expect: false
    }

    it_behaves_like "field", "match by sequence", {
      matching: {text: "\\A.*aBC.*\\z"},
      query: {text: "0ABc"},
      expect: false
    }

    it_behaves_like "field", "match by sequence", {
      matching: {text: "\\A.*aBC.*\\z"},
      query: {text: "ABc9"},
      expect: false
    }

    it_behaves_like "field", "match by sequence", {
      matching: {text: "\\A.*aBC.*\\z"},
      query: {text: "0ABc9"},
      expect: false
    }

    it_behaves_like "field", "pattern match", {
      matching: {text: "\\A0.*aBC\\z"},
      query: {text: "0ABc"},
      expect: false
    }

    it_behaves_like "field", "pattern match 2", {
      matching: {text: "\\A0[1-4]+aBC\\z"},
      query: {text: "01234ABc"},
      expect: false
    }

    it_behaves_like "field", "pattern match 3", {
      matching: {text: "\\A.*0.*aBC\\z"},
      query: {text: "0ABc"},
      expect: false
    }

    it_behaves_like "field", "pattern match 4", {
      matching: {text: "\\A.*0.*aBC\\z"},
      query: {text: "-101ABc"},
      expect: false
    }

    context "when ignore_case option is true" do
      let(:field) { described_class.new(:text, ignore_case: true) }

      it_behaves_like "field", "exact single match", {
        matching: {text: '\\AfoOD\\z'},
        query: {text: "FOod"},
        expect: true
      }

      it_behaves_like "field", "match multiline strings", {
        matching: {text: '\\A.*foOD.*\\z'},
        query: {text: "\r\nFOod\r\n"},
        expect: true
      }

      it_behaves_like "field", "exact single match to multiquery", {
        matching: {text: '\\AfoOD\\z'},
        query: {text: ["games", "FOod"]},
        expect: true
      }

      it_behaves_like "field", "multiple match", {
        matching: {text: ['\\AfoOD\\z', '\\Aclothes\\z']},
        query: {text: "FOod"},
        expect: true
      }

      it_behaves_like "field", "multiple match to multiquery", {
        matching: {text: ['\\AfoOD\\z', '\\Aclothes\\z']},
        query: {text: ["games", "FOod"]},
        expect: true
      }

      it_behaves_like "field", "match by prefix", {
        matching: {text: "\\AaBC.*\\z"},
        query: {text: "ABc"},
        expect: true
      }

      it_behaves_like "field", "match by prefix", {
        matching: {text: "\\AaBC.*\\z"},
        query: {text: "ABc9"},
        expect: true
      }

      it_behaves_like "field", "match by suffix", {
        matching: {text: "\\A.*aBC\\z"},
        query: {text: "0ABc"},
        expect: true
      }

      it_behaves_like "field", "match by suffix", {
        matching: {text: "\\A.*aBC\\z"},
        query: {text: "ABc"},
        expect: true
      }

      it_behaves_like "field", "match by sequence", {
        matching: {text: "\\A.*aBC.*\\z"},
        query: {text: "ABc"},
        expect: true
      }

      it_behaves_like "field", "match by sequence", {
        matching: {text: "\\A.*aBC.*\\z"},
        query: {text: "0ABc"},
        expect: true
      }

      it_behaves_like "field", "match by sequence", {
        matching: {text: "\\A.*aBC.*\\z"},
        query: {text: "ABc9"},
        expect: true
      }

      it_behaves_like "field", "match by sequence", {
        matching: {text: "\\A.*aBC.*\\z"},
        query: {text: "0ABc9"},
        expect: true
      }

      it_behaves_like "field", "pattern match", {
        matching: {text: "\\A0.*aBC\\z"},
        query: {text: "0ABc"},
        expect: true
      }

      it_behaves_like "field", "pattern match 2", {
        matching: {text: "\\A0[1-4]+aBC\\z"},
        query: {text: "01234ABc"},
        expect: true
      }

      it_behaves_like "field", "pattern match 3", {
        matching: {text: "\\A.*0.*aBC\\z"},
        query: {text: "0ABc"},
        expect: true
      }

      it_behaves_like "field", "pattern match 4", {
        matching: {text: "\\A.*0.*aBC\\z"},
        query: {text: "-101ABc"},
        expect: true
      }
    end
  end
end
