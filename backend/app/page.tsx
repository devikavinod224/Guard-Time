import Image from "next/image";
export default function Home() {
  return (
    <div style={{
      display: 'flex',
      justifyContent: 'center',
      alignItems: 'center',
      height: '100vh',
      fontFamily: 'sans-serif',
      backgroundColor: '#f0f2f5',
      color: '#333'
    }}>
      <div style={{ textAlign: 'center' }}>
        <h1 style={{ fontSize: '2.5rem', marginBottom: '1rem' }}>Api Login</h1>
        <p style={{ fontSize: '1.2rem', color: '#666' }}>Hosted By Devika Vinod</p>
      </div>
    </div>
  );
}
