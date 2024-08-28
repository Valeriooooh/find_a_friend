//! This `hub` crate is the
//! entry point of the Rust logic.

mod common;
mod messages;

use common::Result;
use futures::StreamExt;
use iroh::{
    base::node_addr::AddrInfoOptions,
    blobs::store::fs::Store,
    client::docs::{self, ShareMode},
    docs::AuthorId,
    net::relay::RelayMode,
    node::{Node, RpcStatus},
};
use messages::basic::{
    DocumentCreateRequest, DocumentCreateResponse, DocumentListRequest, DocumentListResponse,
};
// use messages;
use tokio; // Comment this line to target the web.
           // use tokio_with_wasm::alias as tokio; // Uncomment this line to target the web.

rinf::write_interface!();

const IROH_DIR: &str = "/data/data/com.example.find_a_friend/files/";

struct App;

impl App {
    async fn new() -> Result<(Node<Store>, AuthorId)> {
        let mut node = Node::persistent(IROH_DIR).await.unwrap();
        let node = node.relay_mode(RelayMode::Default);
        let node = node
            .enable_rpc_with_addr(iroh::node::DEFAULT_RPC_ADDR)
            .await
            .unwrap();
        let node = node.spawn().await.unwrap();
        let _author = node.authors().default().await.unwrap();
        Ok((node, _author))
    }
}

// Use `tokio::spawn` to run concurrent tasks.
// Always use non-blocking async functions
// such as `tokio::fs::File::open`.
// If you really need to use blocking code,
// use `tokio::task::spawn_blocking`.
async fn main() {
    let _ = RpcStatus::clear(IROH_DIR).await;
    let Ok((mut node, author)) = App::new().await else {
        {
            rinf::debug_print!("startup failed!");
            panic!("startup failed!");
        }
    };
    rinf::debug_print!(
        "startup succeded \n\n NodeId: {} \n\n AuthorId {}",
        node.node_id(),
        author.to_string()
    );
    tokio::spawn(doc_list_get(node.clone()));
    tokio::spawn(doc_create(node.clone(), author.clone()));
}

async fn doc_list_get(node: Node<Store>) -> Result<()> {
    let mut sig = DocumentListRequest::get_dart_signal_receiver()?;
    while let Some(dart_signal) = sig.recv().await {
        let mut docs = vec![];
        if let Ok(mut a) = node.docs().list().await {
            while let Some(item) = a.next().await {
                docs.push(item.unwrap());
            }
        };
        rinf::debug_print!("{docs:?}");
        DocumentListResponse {
            document: docs.iter().map(|(x, _)| x.to_string()).collect(),
        }
        .send_signal_to_dart();
    }
    Ok(())
}

async fn doc_create(node: Node<Store>, author: AuthorId) -> Result<()> {
    let mut sig = DocumentCreateRequest::get_dart_signal_receiver()?;
    while let Some(dart_signal) = sig.recv().await {
        let Ok(mut new_doc) = node.docs().create().await else {
            DocumentCreateResponse { ticket: None }.send_signal_to_dart();
            return Ok(());
        };
        let Ok(ticket) = new_doc.share(ShareMode::Write, AddrInfoOptions::Id).await else {
            DocumentCreateResponse { ticket: None }.send_signal_to_dart();
            return Ok(());
        };
        let _ = new_doc
            .set_bytes(author, "share_ticket", ticket.to_string())
            .await;
        DocumentCreateResponse {
            ticket: Some(ticket.to_string()),
        }
        .send_signal_to_dart();
        rinf::debug_print!("{ticket:?}");
    }
    Ok(())
}
