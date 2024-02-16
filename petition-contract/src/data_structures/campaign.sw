library;

pub struct Campaign {
    // Unique identifier for the campaign
    id: u64,
}

impl Campaign {
    pub fn new(id: u64) -> Self {
        Self { id }
    }
}