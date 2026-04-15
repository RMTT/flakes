return {
    "chrisgrieser/nvim-early-retirement",
    config = function()
        require("early-retirement").setup {
            retirementAgeMins = 10
        }
    end
}
